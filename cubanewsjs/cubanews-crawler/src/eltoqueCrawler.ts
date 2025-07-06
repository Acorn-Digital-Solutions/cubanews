import { Moment } from "moment";
import { Page } from "playwright";
import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import moment from "moment";

export default class ElToqueCrawler extends CubanewsCrawler {
  constructor() {
    super(getNewsSourceByName(NewsSourceName.ELTOQUE));
    this.enqueueLinkOptions = {
      globs: ["http?(s)://eltoque.com/*"],
      exclude: [
        "https://eltoque.com/search",
        "https://eltoque.com/sobre-nosotros",
        "https://eltoque.com/multimedia",
        "https://eltoque.com/coverturas",
        "https://eltoque.com/revistas",
        "https://eltoque.com/newsletters",
        "https://eltoque.com/tasas-de-cambio-de-moneda-en-cuba-hoy*",
        "https://eltoque.com/especiales",
      ],
      selector: "div.container-fluid a",
    };
  }

  protected override isUrlValid(url: string): boolean {
    return !this.newsSource.startUrls.has(url);
  }

  protected override async extractDate(page: Page): Promise<Moment | null> {
    const articleHeader = await page
      .locator("div.article-header")
      .first()
      .textContent();
    const matches = articleHeader?.match(
      /(enero|febrero|marzo|abril|mayo|junio|julio|agosto|septiembre|octubre|noviembre|diciembre)\s+\d{1,2},\s+\d{4}/i
    );
    moment.locale("es");
    if (!matches || matches?.length === 0) {
      return null;
    }
    const mDate = moment(matches[0], "MMMM D, YYYY");
    if (mDate.isSameOrAfter(moment.now())) {
      console.warn(`Date is in the future: ${matches[0]}`);
      return moment(new Date());
    }
    return mDate;
  }

  protected override async extractContent(page: Page): Promise<string | null> {
    var content = await page
      .locator("article > div:nth-of-type(3)")
      .textContent();
    if (content) {
      content = content.split(" ").slice(0, 50).join(" ");
    }
    return content;
  }
}
