import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import moment from "moment";
import { Page } from "playwright";
import log from "@apify/log";

export default class CatorceYMedioCrawler extends CubanewsCrawler {
  constructor() {
    super(getNewsSourceByName(NewsSourceName.CATORCEYMEDIO));
    this.enqueueLinkOptions = {
      globs: ["http?(s)://www.14ymedio.com/cuba/*"],
      exclude: [
        "https://www.14ymedio.com/cuba/terminos-condiciones_1_1048711.html",
      ],
      selector: "a",
    };
  }

  protected override async extractDate(
    page: Page
  ): Promise<moment.Moment | null> {
    try {
      const rawDate = await page
        .locator(".timestamp-atom")
        .first()
        .textContent();
      if (!rawDate) {
        return null;
      }
      moment.locale("es");
      const mDate = moment(rawDate.trim(), "DD [de] MMMM YYYY - HH:mm");
      // TODO:: Sometimes the date is in the future. This is a patch to prevent that from happening.
      // It may be a parsing error.
      if (mDate.isSameOrAfter(moment.now())) {
        return moment(new Date());
      }
      return mDate;
    } catch (error: any) {
      log.error(`Error extracting date from ${page.url}`, { error: error });
      return null;
    }
  }

  protected override async extractContent(page: Page): Promise<string | null> {
    return await page.locator(".bbnx-body").textContent();
  }

  protected override isUrlValid(url: string): boolean {
    const sections = url.split("/");
    return sections.length >= 5;
  }

  protected override imageSelector(): string {
    return "main picture img";
  }
}
