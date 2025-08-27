import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import moment from "moment";
import { Page } from "playwright";

const newsSource = getNewsSourceByName(NewsSourceName.DIARIODECUBA);

export default class DiarioDeCubaCrawler extends CubanewsCrawler {
  protected override imageSelector(): string {
    throw new Error("Method not implemented.");
  }
  constructor() {
    super(newsSource);
    this.enqueueLinkOptions = {
      globs: ["http?(s)://diariodecuba.com/*/*"],
      exclude: [
        "https://diariodecuba.com/user/login",
        "https://diariodecuba.com/de-leer/**",
      ],
      selector: "a",
    };
  }

  protected override isUrlValid(url: string): boolean {
    const sections = url.split("/");
    return sections.length >= 5;
  }

  protected override async extractDate(
    page: Page
  ): Promise<moment.Moment | null> {
    const rawDate = await page.locator("time.date").first().textContent();
    if (!rawDate) {
      return null;
    }
    moment.locale("es");
    const mDate = moment(rawDate.trim(), "DD MMMM YYYY - HH:mm Z");
    // TODO:: Sometimes the date is in the future. This is a patch to prevent that from happening.
    // It may be a parsing error.
    if (mDate.isSameOrAfter(moment.now())) {
      console.warn(`Date is in the future: ${rawDate}`);
      return moment(new Date());
    }
    return mDate;
  }

  protected override async extractContent(page: Page): Promise<string | null> {
    return await page.locator("div.content").first().textContent();
  }

  parseDate(rawDate: string): moment.Moment {
    moment.locale("es");
    const mDate = moment(rawDate.trim(), "DD MMMM YYYY - HH:mm Z");
    // TODO:: Sometimes the date is in the future. This is a patch to prevent that from happening.
    // It may be a parsing error.
    if (mDate.isSameOrAfter(moment.now())) {
      console.warn(`Date is in the future: ${rawDate}`);
      return moment(new Date());
    }
    return mDate;
  }
}
