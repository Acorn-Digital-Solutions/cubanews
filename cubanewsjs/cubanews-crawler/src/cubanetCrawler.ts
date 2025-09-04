import { Moment } from "moment";
import { Page } from "playwright";
import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import moment from "moment";

export default class CubanetCrawler extends CubanewsCrawler {
  protected override imageSelector(): string {
    return "figure.wp-caption > img";
  }

  constructor() {
    super(getNewsSourceByName(NewsSourceName.CUBANET));
    this.enqueueLinkOptions = {
      globs: ["http?(s)://www.cubanet.org/*/"],
      selector: "a.elementor-post__thumbnail__link",
    };
  }

  protected override isUrlValid(url: string): boolean {
    return (
      url !== "https://www.cubanet.org/" &&
      !url.startsWith("https://www.cubanet.org/categoria/") &&
      !url.startsWith("https://www.cubanet.org/author/") &&
      !url.startsWith("https://www.cubanet.org/tags/") &&
      url !== "https://www.cubanet.org/tag/reportajes-investigativos/" &&
      url !== "https://www.cubanet.org/htdocs/oldies.html"
    );
  }

  protected override async extractDate(page: Page): Promise<Moment | null> {
    const rawDate = await page
      .locator(".elementor-post-info__item--type-date")
      .first()
      .textContent();
    const rawTime = await page
      .locator(".elementor-post-info__item--type-time")
      .last()
      .textContent();
    if (!rawDate && !rawTime) {
      return null;
    }
    moment.locale("es");
    const mDate = moment(
      `${rawDate?.trim()} ${rawTime?.trim()}`,
      "MMMM D, yyyy h:mm a"
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
    const content = await page
      .locator(
        "div.elementor-element.elementor-widget.elementor-widget-theme-post-content"
      )
      .first()
      .textContent();
    return content;
  }
}
