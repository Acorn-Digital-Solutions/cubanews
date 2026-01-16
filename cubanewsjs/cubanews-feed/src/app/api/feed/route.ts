import {
  FeedResponseData,
  Interaction,
  NewsItem,
  NewsSourceName,
} from "../../interfaces";
import { NextRequest, NextResponse } from "next/server";
import { ApifyClient, Dataset } from "apify-client";
import { sql } from "kysely";
import { xOfEachSource } from "./feedStrategies";
import { newsItemToFeedTable } from "@/local/localFeedLib";
import cubanewsApp from "@/app/cubanewsApp";
import {
  AdnCubaRSSCrawler,
  CatorceYMedioRSSCrawler,
  CibercubaRSSCrawler,
  CubanetRSSCrawler,
  CubanosPorElMundoRSSCrawler,
  DirectorioCubanoRSSCrawler,
  MartiNoticiasRSSCrawler,
} from "@/app/cubanewsRSSCrawler";

export type RefreshFeedResult = {
  datasetName: string;
  insertedRows: bigint | number;
};

const db = cubanewsApp.getDatabase;
const client = new ApifyClient({
  token: process.env.APIFY_TOKEN,
});

export async function GET(
  request: NextRequest,
): Promise<NextResponse<FeedResponseData | null>> {
  if (request.nextUrl.searchParams.get("refresh")) {
    if (request.headers.get("ADMIN_TOKEN") !== process.env.ADMIN_TOKEN) {
      return NextResponse.json(
        {
          banter: "You are not authorized to refresh the feed",
        },
        { status: 401, statusText: "Unauthorized" },
      );
    }
    if (request.nextUrl.searchParams.get("dryrun")) {
      return NextResponse.json(
        {
          banter: "Dry Run. Refreshing cubanews feed",
        },
        { status: 200 },
      );
    }

    refreshFeed()
      .then((data) => console.log(data))
      .catch((error) => console.error(error));

    return NextResponse.json(
      {
        banter: "Refreshing cubanews feed",
      },
      { status: 200 },
    );
  }

  const page = parseInt(request.nextUrl.searchParams.get("page") ?? "1");
  const pageSize = parseInt(
    request.nextUrl.searchParams.get("pageSize") ?? "2",
  );

  return getFeed(page, pageSize);
}

async function getFeed(
  page: number,
  pageSize: number,
): Promise<NextResponse<FeedResponseData | null>> {
  const latestFeedts = await db
    .selectFrom("feed")
    .select([sql`max(feed.feedts)`.as("feedts")])
    .executeTakeFirst();

  if (!latestFeedts?.feedts) {
    return NextResponse.json(
      {
        banter: "No feeds available",
      },
      { status: 500 },
    );
  }

  // This strategy gets the top x news of every source.
  // X is the page size, if implemented page 2 would mean skipping the first x for each news source
  // and getting the following x. This is temporary until a better, ranked version of the feed is conceived.
  const items = await xOfEachSource(db, page, pageSize);

  const itemsMap = new Map<number, NewsItem>();
  items.forEach((x) => {
    itemsMap.set(x.id as number, x);
  });

  const interactions = await db
    .selectFrom("interactions")
    .select([
      "interaction",
      "feedid",
      db.fn.count("id").$castTo<string>().as("count"),
    ])
    .where(
      "feedid",
      "in",
      items.map((x) => x.id as number),
    )
    .groupBy("interaction")
    .groupBy("feedid")
    .execute();

  interactions.forEach((x) => {
    const action: Interaction = x.interaction;
    const feedid = x.feedid as number;
    const count = parseInt(x.count);
    const item = itemsMap.get(feedid);
    if (item && item.interactions) {
      item.interactions[action] = count;
    }
  });

  const timestamp = items.length > 0 ? items[0].feedts : 0;

  return NextResponse.json(
    {
      banter: "Cubanews feed!",
      content: {
        timestamp,
        feed: Array.from(itemsMap.values()),
      },
    },
    { status: 200 },
  );
}

async function refreshFeed(): Promise<Array<RefreshFeedResult>> {
  const feedRefreshDate = new Date();
  const ARTICLE_LIMIT = 10;
  const results: RefreshFeedResult[] = [];

  // Define all crawlers with their corresponding NewsSourceName
  const crawlers = [
    {
      crawler: new CatorceYMedioRSSCrawler(),
      source: NewsSourceName.CATORCEYMEDIO,
    },
    { crawler: new CibercubaRSSCrawler(), source: NewsSourceName.CIBERCUBA },
    {
      crawler: new DirectorioCubanoRSSCrawler(),
      source: NewsSourceName.DIRECTORIO_CUBANO,
    },
    { crawler: new AdnCubaRSSCrawler(), source: NewsSourceName.ADNCUBA },
    {
      crawler: new MartiNoticiasRSSCrawler(),
      source: NewsSourceName.MARTI_NOTICIAS,
    },
    {
      crawler: new CubanosPorElMundoRSSCrawler(),
      source: NewsSourceName.CUBANOS_POR_EL_MUNDO,
    },
    { crawler: new CubanetRSSCrawler(), source: NewsSourceName.CUBANET },
  ];

  // Process each crawler
  for (const { crawler, source } of crawlers) {
    try {
      const articles = await crawler.getRSSContent(true, ARTICLE_LIMIT);
      const newsItems = articles.map((article) =>
        rssArticleToNewsItem(article, source),
      );
      const result = await insertArticlesToFeed(
        newsItems,
        feedRefreshDate,
        source,
      );
      results.push(result);
    } catch (error) {
      console.error(`Error processing ${source}:`, error);
      results.push({
        datasetName: source,
        insertedRows: 0,
      });
    }
  }

  return results;
}

function rssArticleToNewsItem(article: any, source: NewsSourceName): NewsItem {
  return {
    id: 0, // Will be assigned by database
    title: article.title,
    source: source,
    url: article.link,
    updated: new Date(article.pubDate).getTime(),
    isoDate: article.isoDate,
    feedts: null,
    content: article.contentSnippet || article.content,
    tags: article.categories || [],
    score: 0,
    interactions: { feedid: 0, view: 0, like: 0, share: 0 },
    aiSummary: "",
    image: article.image || "",
  };
}

async function insertArticlesToFeed(
  newsItems: NewsItem[],
  feedRefreshDate: Date,
  sourceName: NewsSourceName,
): Promise<RefreshFeedResult> {
  const validItems = newsItems.filter((newsItem) => isNewsItemValid(newsItem));

  if (validItems.length === 0) {
    return {
      datasetName: sourceName,
      insertedRows: 0,
    };
  }

  // Get existing URLs from the database for articles from the last 48 hours
  const urls = validItems.map((item) => item.url);
  const fortyEightHoursAgo = Date.now() - 48 * 60 * 60 * 1000;

  const existingUrls = await db
    .selectFrom("feed")
    .select("url")
    .where("url", "in", urls)
    .where("updated", ">=", fortyEightHoursAgo)
    .execute();

  const existingUrlSet = new Set(existingUrls.map((row) => row.url));

  // Filter out items that already exist in the database
  const newItems = validItems.filter((item) => !existingUrlSet.has(item.url));

  if (newItems.length === 0) {
    return {
      datasetName: sourceName,
      insertedRows: 0,
    };
  }

  const values = await Promise.all(
    newItems.map((x) => newsItemToFeedTable(x, feedRefreshDate) as any),
  );

  const insertResult = await db
    .insertInto("feed")
    .values(values)
    .executeTakeFirst();

  return {
    datasetName: sourceName,
    insertedRows: insertResult.numInsertedOrUpdatedRows?.valueOf() as bigint,
  };
}

async function refreshFeedDataset(
  dataset: Dataset,
  feedRefreshDate: Date,
): Promise<RefreshFeedResult> {
  if (!dataset || !dataset.name) {
    return { datasetName: "unknown", insertedRows: 0 };
  }
  const { items } = await client.dataset(dataset.id).listItems();
  const newsItems = items
    .map((item) => item as unknown)
    .map((item) => item as NewsItem);
  const values = newsItems
    .filter((newsItem) => isNewsItemValid(newsItem))
    .map((x) => newsItemToFeedTable(x, feedRefreshDate) as any);
  const insertResult = await db
    .insertInto("feed")
    .values(values)
    .executeTakeFirst();

  return {
    datasetName: dataset.name as string,
    insertedRows: insertResult.numInsertedOrUpdatedRows?.valueOf() as bigint,
  };
}

function isNewsItemValid(newsItem: NewsItem): boolean {
  return (
    newsItem.isoDate !== null &&
    newsItem.updated !== null &&
    newsItem.title !== null &&
    newsItem.title.length > 0 &&
    newsItem.url !== null &&
    newsItem.url.length > 0
  );
}
