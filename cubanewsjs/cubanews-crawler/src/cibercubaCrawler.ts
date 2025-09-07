import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import moment from "moment";
import { Page } from "playwright";

const newsSource = getNewsSourceByName(NewsSourceName.CIBERCUBA);
const dateFormats = ["dddd, DD MMMM, YYYY - HH:mm", "DD/MM/YYYY - h:mma (ZZ)"];

export default class CibercubaCrawler extends CubanewsCrawler {
  protected override imageSelector(): string {
    return "div > article > div > div.col-md-8.col-sm-12.col-xs-12 > div.cibercuba-article-content > div.cibercuba-img-header > figure > amp-img > img.i-amphtml-fill-content.i-amphtml-replaced-content";
  }

  constructor() {
    super(newsSource);
    this.enqueueLinkOptions = {
      globs: ["http?(s)://www.cibercuba.com/noticias/*"],
      exclude: ["https://www.cibercuba.com/buscador*"],
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
    var rawDate = await page
      .locator("div.cibercuba-article-author > p > strong:nth-child(1)")
      .first()
      .textContent();
    console.log(rawDate);
    if (!rawDate) {
      return null;
    }
    rawDate = rawDate.replace("(GMT-5)", "-0500");
    moment.locale("es");

    let i = 1;
    let mDate = moment(rawDate.trim(), dateFormats[0]);
    while (i < dateFormats.length && !mDate.isValid()) {
      mDate = moment(rawDate.trim(), dateFormats[i++]);
    }

    // TODO:: Sometimes the date is in the future. This is a patch to prevent that from happening.
    // It may be a parsing error.
    if (mDate.isSameOrAfter(moment.now())) {
      console.warn(`Date is in the future: ${rawDate}`);
      return moment(new Date());
    }
    return mDate;
  }

  protected override async extractContent(page: Page): Promise<string | null> {
    return await page.locator("#textolimpio").innerText();
  }
}
