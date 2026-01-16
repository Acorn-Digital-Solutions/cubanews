import { Database, FeedTable } from "@/app/api/dataschema";
import { RefreshFeedResult } from "@/app/api/feed/route";
import { NewsItem, NewsSourceName } from "@/app/interfaces";
import { info } from "console";
import * as fs from "fs";
import * as path from "path";
import { InsertQueryBuilder, Kysely } from "kysely";
import { getFeedScore } from "@/app/api/feed/feedScoreStrategies";

/**
 * Configures the onConflict clause for feed insertions to handle duplicate URLs.
 * When a URL conflict occurs, updates the existing record with new data.
 * 
 * @param query - The Kysely insert query builder to configure
 * @returns The configured query builder with onConflict clause
 * 
 * @remarks
 * This function applies an UPSERT strategy using PostgreSQL's ON CONFLICT DO UPDATE.
 * When a duplicate URL is detected, it updates the existing record with new values
 * for all fields except the primary key (id) and the conflict column (url).
 * 
 * **Maintenance Note**: When new fields are added to the FeedTable schema, they must
 * be added to the doUpdateSet clause below to ensure they are updated on conflict.
 */
export function applyFeedUpsertOnConflict<T>(
  query: InsertQueryBuilder<Database, "feed", T>,
): InsertQueryBuilder<Database, "feed", T> {
  return query.onConflict((oc) =>
    oc.column("url").doUpdateSet({
      feedts: (eb) => eb.ref("excluded.feedts"),
      feedisodate: (eb) => eb.ref("excluded.feedisodate"),
      source: (eb) => eb.ref("excluded.source"),
      title: (eb) => eb.ref("excluded.title"),
      content: (eb) => eb.ref("excluded.content"),
      updated: (eb) => eb.ref("excluded.updated"),
      isodate: (eb) => eb.ref("excluded.isodate"),
      score: (eb) => eb.ref("excluded.score"),
      tags: (eb) => eb.ref("excluded.tags"),
      imageurl: (eb) => eb.ref("excluded.imageurl"),
    }),
  );
}

export async function newsItemToFeedTable(
  ni: NewsItem,
  currentDate: Date
): Promise<FeedTable> {
  const isoDateString = currentDate.toISOString();
  const epochTimestamp = currentDate.getTime();

  const score = await getFeedScore(ni);
  return {
    content: ni.content,
    feedisodate: isoDateString,
    feedts: epochTimestamp,
    isodate: ni.isoDate,
    source: ni.source,
    title: ni.title,
    updated: ni.updated,
    url: ni.url,
    score: score,
    imageurl: ni.image,
    tags: ni.tags.join(","),
  } as FeedTable;
}

export async function loadLocalDataset(
  datasetPath: string
): Promise<Array<NewsItem>> {
  return new Promise((resolve, reject) => {
    fs.readdir(datasetPath, (err, files) => {
      if (err) {
        return reject(err);
      }

      const jsonFiles = files.filter((file) => file.endsWith(".json"));
      const readPromises = jsonFiles.map((file) => {
        return new Promise<NewsItem>((res, rej) => {
          const filePath = path.join(datasetPath, file);
          fs.readFile(filePath, "utf-8", (readErr, data) => {
            if (readErr) {
              return rej(readErr);
            }
            try {
              const jsonData = JSON.parse(data);
              res(jsonData);
            } catch (parseErr) {
              rej(parseErr);
            }
          });
        });
      });

      Promise.all(readPromises)
        .then((contents) => resolve(contents))
        .catch((readErr) => reject(readErr));
    });
  });
}

async function refreshFeedDataset(
  datasetName: string,
  feedRefreshDate: Date,
  newsItems: Array<NewsItem>,
  db: Kysely<Database>
): Promise<RefreshFeedResult> {
  const values = await Promise.all(
    newsItems.map((x) => newsItemToFeedTable(x, feedRefreshDate) as any)
  );
  console.info(values);
  const insertResult = await applyFeedUpsertOnConflict(
    db.insertInto("feed").values(values),
  ).executeTakeFirst();

  return {
    datasetName: datasetName,
    insertedRows: insertResult.numInsertedOrUpdatedRows?.valueOf() as bigint,
  };
}

export async function refreshFeedFromLocalSources(
  db: Kysely<Database>
): Promise<RefreshFeedResult[]> {
  const localDatasourcePaths = [
    [
      NewsSourceName.DIARIODECUBA,
      "../ddc-crawler/storage/datasets/diariodecuba-dataset",
    ],
    [
      NewsSourceName.CATORCEYMEDIO,
      "../catorceYmedio-crawler/storage/datasets/catorceymedio-dataset",
    ],
    [
      NewsSourceName.ADNCUBA,
      "../adncuba-crawler/storage/datasets/adncuba-dataset",
    ],
    [
      NewsSourceName.CIBERCUBA,
      "../cibercuba-crawler/storage/datasets/cibercuba-dataset",
    ],
    [
      NewsSourceName.CUBANET,
      "../cubanet-crawler/storage/datasets/cubanet-dataset",
    ],
    [
      NewsSourceName.ELTOQUE,
      "../eltoque-crawler/storage/datasets/eltoque-dataset",
    ],
  ];
  const feedDate = new Date();
  const res = localDatasourcePaths.map(async (x) => {
    info(`Refreshing feed for ${x[0]}`);
    return refreshFeedDataset(x[0], feedDate, await loadLocalDataset(x[1]), db);
  });
  return Promise.all(res);
}
