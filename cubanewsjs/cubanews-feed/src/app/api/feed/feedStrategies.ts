import { NewsItem } from "@/app/interfaces";
import { Kysely, sql } from "kysely";
import { Database, FeedTable } from "../dataschema";

function dbItemToNewsItem(dbitem: any): NewsItem {
  return {
    id: dbitem.id,
    title: dbitem.title,
    source: dbitem.source,
    url: dbitem.url,
    updated: dbitem.updated,
    isoDate: dbitem.isodate.toString(),
    feedts: dbitem.feedts,
    content: dbitem.content,
    tags: dbitem.tags ? dbitem.tags.split(",") : [],
    score: dbitem.score,
    image: dbitem.imageurl,
    interactions: {
      feedid: dbitem.feedid,
      view: 0,
      like: 0,
      share: 0,
    },
  } as NewsItem;
}

/**
 *
 * @param db
 * @param feedts Timestamp of the feed. This guaranties that only the latest items are considered.
 * @param page Starts on 1
 * @returns
 */
export async function xOfEachSource(
  db: Kysely<Database>,
  page: number,
  pageSize: number,
): Promise<Array<NewsItem>> {
  const query = sql<FeedTable>`
  SELECT *
  FROM (
   SELECT *, ROW_NUMBER() OVER (PARTITION BY
   source ORDER BY updated desc) AS row_number
   FROM feed where isodate is not null AND updated is not null AND isodate::timestamp >= NOW() - INTERVAL '48 hours'
  ) AS t
  WHERE t.row_number > ${pageSize * (page - 1)} AND t.row_number <= ${
    pageSize * page
  }
  order by score desc, updated desc
  `;
  const result = (await query.execute(db)).rows;
  return result.map(dbItemToNewsItem);
}

export async function allSortedByUpdated(
  db: Kysely<Database>,
  feedts: number,
  page: number,
  pageSize: number,
): Promise<Array<NewsItem>> {
  const feeds = await db
    .selectFrom("feed")
    .selectAll()
    .where("feed.feedts", "=", feedts)
    .where("isodate", "!=", null)
    .where("updated", "!=", null)
    .orderBy("score desc")
    .orderBy("updated desc")
    .offset((page - 1) * pageSize)
    .limit(pageSize)
    .execute();

  return feeds.map(dbItemToNewsItem);
}
