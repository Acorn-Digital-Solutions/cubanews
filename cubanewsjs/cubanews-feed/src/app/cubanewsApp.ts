import { Database, SubscriptionsTable } from "@/app/api/dataschema";
import { Kysely, PostgresDialect, sql } from "kysely";
import { Pool } from "pg";
import { createKysely } from "@vercel/postgres-kysely";
import * as dotenv from "dotenv";
import { xOfEachSource } from "./api/feed/feedStrategies";
import {
  getNewsSourceDisplayName,
  NewsItem,
  NewsSourceName,
} from "./interfaces";
import path from "path";
import fs from "fs";
import moment from "moment";
import { fileURLToPath } from "url";

dotenv.config({
  path: process.env.ENV_FILE ?? `.env`,
});
export class CubanewsApp {
  private database: Kysely<Database>;
  private dirname = path.dirname(fileURLToPath(import.meta.url));

  constructor() {
    console.log(
      "Initialising Cubanews App for environment, ",
      process.env.LOCAL_ENV
    );
    if (process.env.LOCAL_ENV === "development") {
      console.log("Using local database");
      const dialect = new PostgresDialect({
        pool: new Pool({
          database: process.env.POSTGRES_DATABASE,
          host: process.env.POSTGRES_HOST,
          user: process.env.POSTGRES_USER,
          password: process.env.POSTGRES_PASSWORD,
          port: 9000,
          max: 10,
        }),
      });
      this.database = new Kysely<Database>({
        dialect,
      });
    } else {
      dotenv.config({
        path: `.env`,
      });
      this.database = createKysely<Database>();
    }
  }

  public get getDatabase() {
    return this.database;
  }

  async getFeedItems(): Promise<NewsItem[]> {
    const latestFeedts = await this.database
      .selectFrom("feed")
      .select([sql`max(feed.feedts)`.as("feedts")])
      .executeTakeFirst();
    if (!latestFeedts?.feedts) {
      return [];
    }

    const items = await xOfEachSource(
      this.database,
      latestFeedts.feedts as number,
      1,
      2
    );
    return items;
  }

  async getFBPostNewsItems(): Promise<NewsItem[]> {
    const latestFeedts = await this.database
      .selectFrom("feed")
      .select([sql`max(feed.feedts)`.as("feedts")])
      .executeTakeFirst();
    if (!latestFeedts?.feedts) {
      return [];
    }
    const items = await xOfEachSource(
      this.database,
      latestFeedts.feedts as number,
      1,
      1
    );
    return items;
  }

  async getRecipients(): Promise<string[]> {
    const query = sql<SubscriptionsTable>`select s.* from subscriptions s join 
      (select max(timestamp) as ts from subscriptions 
      group by email) x on s.timestamp=x.ts where status='subscribed'`;
    const result = (await query.execute(this.database)).rows;
    return result.map((r) => r.email);
  }

  getNewsSourceLogoUrl(item: NewsItem): string {
    const newsSource = item.source;
    switch (newsSource) {
      case NewsSourceName.ADNCUBA:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2Fadncuba1.webp&w=48&q=75";
      case NewsSourceName.CATORCEYMEDIO:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2F14ymedio1.jpg&w=48&q=75";
      case NewsSourceName.CIBERCUBA:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2Fcibercuba1.png&w=48&q=75";
      case NewsSourceName.CUBANET:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2Fcubanet2.jpeg&w=48&q=75";
      case NewsSourceName.DIARIODECUBA:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2Fddc1.webp&w=48&q=75";
      case NewsSourceName.ELTOQUE:
        return "https://www.cubanews.icu/_next/image?url=%2Fsource_logos%2Feltoque.png&w=48&q=75";
      default:
        return "";
    }
  }

  async getEmailBody(): Promise<string> {
    const feed = await cubanewsApp.getFeedItems();

    const templatePath = path.join(this.dirname, "mail_template.html");
    const emailTemplate = fs.readFileSync(templatePath, { encoding: "utf-8" });

    const itemTemplatePath = path.join(this.dirname, "news_item_template.html");
    const itemTemplate = fs.readFileSync(itemTemplatePath, {
      encoding: "utf-8",
    });

    var body = "";
    moment.locale("es");
    for (const item of feed) {
      const itemDate = moment(item.isoDate);
      var itemHtml = itemTemplate
        .replace("${news_source_logo}", cubanewsApp.getNewsSourceLogoUrl(item))
        .replace("${title}", item.title)
        .replace("${url}", item.url)
        .replace("${news_source_name}", getNewsSourceDisplayName(item))
        .replace("${content}", item.content ?? "")
        .replace("${news-date}", itemDate.format("DD-MM-YYYY hh:mm A"));
      body += itemHtml;
    }

    const today = moment();
    const res = emailTemplate
      .replace("${news}", body)
      .replace("${date}", today.format("LL"));
    return res;
  }
}

const cubanewsApp = new CubanewsApp();
export default cubanewsApp;
