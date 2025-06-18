import * as nodemailer from "nodemailer";
import {
  NewsItem,
  NewsSourceName,
  getNewsSourceDisplayName,
} from "@/app/interfaces";
import { SubscriptionsTable } from "@/app/api/dataschema";
import { sql } from "kysely";
import { xOfEachSource } from "@/app/api/feed/feedStrategies";
import path from "path";
import fs from "fs";
import moment from "moment";
import cubanewsApp from "@/app/cubanewsApp";
import { fileURLToPath } from "url";
import { getLlama, LlamaChatSession } from "node-llama-cpp";

const from = "cubanews.icu@gmail.com";
const db = cubanewsApp.getDatabase;

export async function getFeedItems(): Promise<NewsItem[]> {
  const latestFeedts = await db
    .selectFrom("feed")
    .select([sql`max(feed.feedts)`.as("feedts")])
    .executeTakeFirst();
  if (!latestFeedts?.feedts) {
    return [];
  }

  const items = await xOfEachSource(db, latestFeedts.feedts as number, 1, 2);
  return items;
}

export const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "cubanews.icu@gmail.com",
    pass: process.env.MAIL_PWD,
  },
});

async function getRecipients(): Promise<string[]> {
  const query = sql<SubscriptionsTable>`select s.* from subscriptions s join 
    (select max(timestamp) as ts from subscriptions 
    group by email) x on s.timestamp=x.ts where status='subscribed'`;
  const result = (await query.execute(db)).rows;
  return result.map((r) => r.email);
}

function getNewsSourceLogoUrl(item: NewsItem): string {
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

async function getEmailBody(): Promise<string> {
  const feed = await getFeedItems();

  const templatePath = path.join(__dirname, "mail_template.html");
  const emailTemplate = fs.readFileSync(templatePath, { encoding: "utf-8" });

  const itemTemplatePath = path.join(__dirname, "news_item_template.html");
  const itemTemplate = fs.readFileSync(itemTemplatePath, { encoding: "utf-8" });

  var body = "";
  moment.locale("es");
  for (const item of feed) {
    const itemDate = moment(item.isoDate);
    var itemHtml = itemTemplate
      .replace("${news_source_logo}", getNewsSourceLogoUrl(item))
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

export async function generateAISummary(): Promise<string> {
  const feed = await getFeedItems();
  if (feed.length === 0) {
    return "No hay noticias para resumir.";
  }

  // Here you would typically call an AI service to generate a summary.
  // For simplicity, we will just return a placeholder text.

  const __dirname = path.dirname(fileURLToPath(import.meta.url));
  const llama = await getLlama();
  const model = await llama.loadModel({
    modelPath: path.join(
      __dirname,
      "models",
      "Meta-Llama-3.1-8B-Instruct.Q4_K_M.gguf"
    ),
  });
  const context = await model.createContext();
  const session = new LlamaChatSession({
    contextSequence: context.getSequence(),
  });
  const message = await session.prompt("Say hello to the user.");
  console.log("AI response:", message);
  return message;
}

export async function sendEmails() {
  const recipients = await getRecipients();
  if (recipients.length === 0) {
    return;
  }
  const today = moment();
  const mailOptions = {
    from: from,
    to: "",
    bcc: recipients.join(";"),
    subject: `CubaNews resumen ${today.format("LL")}`,
    html: await getEmailBody(),
  };

  transporter.sendMail(mailOptions, (error, info) => {
    if (error) {
      console.error("Error occurred:", error);
    } else {
      console.log("Email sent:", info.response);
    }
  });
}

(async () => {
  try {
    await sendEmails();
  } catch (error) {
    console.error("Error sending emails ", error);
  }
})();
