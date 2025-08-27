/**
 * This is the ADN Cuba homepage crawler.
 * It is aiming to crawl the home page of ADN Cuba and extract all the direct links to articles
 * present in the page. Only one level.
 * The articles are encapsulated in an <article> tab and contain a link inside that fits the pattern
 * https://adncuba.com/asd/asdx
 */
import moment from "moment";
import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import { Page } from "playwright";
import path from "path";
import * as fs from "fs";

const newsSource = getNewsSourceByName(NewsSourceName.ADNCUBA);
const dateFormats = ["MMMM D, YYYY h:mma", "ddd, MM/DD/YYYY - HH:mm"];

export default class AdnCubaCrawler extends CubanewsCrawler {
  private httpStart = "http?(s)://";
  constructor() {
    super(newsSource);
    const excludeRegexRoutes = [
      "adncuba.com/tags/*",
      "adncuba.com/es/taxonomy/*",
      "adncuba.com/es/sur-de-la-florida",
      "adncuba.com/es/node/*",
      "adncuba.com/es/america-latina/colombia",
      "adncuba.com/es/america-latina/mexico",
      "adncuba.com/es/america-latina/venezuela",
    ].map((r) => `${this.httpStart}${r}`);
    this.enqueueLinkOptions = {
      globs: ["http?(s)://adncuba.com/es/*/*"],
      exclude: excludeRegexRoutes,
      selector: "a",
    };
  }

  protected override isUrlValid(url: string): boolean {
    const sections = url.split("/");
    return !url.startsWith("https://adncuba.com/tags/") && sections.length >= 6;
  }

  protected override async extractDate(
    page: Page
  ): Promise<moment.Moment | null> {
    const rawDate = await page
      .locator("p.updated__paragraph")
      .first()
      .textContent();
    if (!rawDate) {
      return null;
    }
    let i = 1;
    const rawDateSplit = rawDate.trim().split(": ")[1];
    let mDate = moment(rawDateSplit, dateFormats[0]);
    while (i < dateFormats.length && !mDate.isValid) {
      mDate = moment(rawDateSplit, dateFormats[i]);
      i++;
    }
    this.log.info(
      `Date ${rawDateSplit} parsed using format ${dateFormats[i - 1]}`
    );
    // TODO:: Sometimes the date is in the future. This is a patch to prevent that from happening.
    // It may be a parsing error.
    if (mDate.isSameOrAfter(moment.now())) {
      console.warn(`Date is in the future: ${rawDate}`);
      return moment(new Date());
    }
    return mDate;
  }

  protected override async extractContent(page: Page): Promise<string | null> {
    var content = await page.locator(".text-long").textContent();
    if (content) {
      content = content
        .trim()
        .replace(/\n/g, "")
        .split(" ")
        .slice(0, 50)
        .join(" ");
    }
    return content;
  }

  protected override imageSelector(): string {
    return "picture img";
  }
}
