import { Page } from "playwright";
import { CubanewsCrawler } from "./cubanewsCrawler.js";
import { getNewsSourceByName, NewsSourceName } from "./crawlerUtils.js";
import moment from "moment";

export default class PeriodicoCubanoCrawler extends CubanewsCrawler {
  protected override imageSelector(): string {
    return "a > img";
  }
  private httpStart = "https://www.periodicocubano.com/";
  private excludeRegexRoutes = [
    "noticias-de-los-estados-unidos/*",
    "noticias/parole-humanitario/*",
    "ley-de-nietos-y-bisnietos/*",
    "farandula-famosos-artistas/*",
    "numeros-ganadores-charada-cubana/*",
  ].map((r) => `${this.httpStart}${r}`);
  constructor() {
    super(getNewsSourceByName(NewsSourceName.PERIODICO_CUBANO));

    this.enqueueLinkOptions = {
      globs: ["http?(s)://www.periodicocubano.com/*/"],
      selector: "#mvp-tab-col1 > ul > li > div > a",
      exclude: this.excludeRegexRoutes,
    };
  }

  protected override isUrlValid(url: string): boolean {
    const invalid = this.excludeRegexRoutes
      .map((route) => {
        return url.startsWith(route);
      })
      .reduce((prev, current) => prev && current);
    const sections = url.split("/");
    console.info("Is url valid", url);
    return !invalid && sections.length === 4;
  }
  protected override async extractDate(
    page: Page
  ): Promise<moment.Moment | null> {
    moment.locale("es");
    const format = "D [de] MMMM YYYY h:mm A";
    const rawDate = await page
      .locator("span.post-date.updated")
      .first()
      .textContent();
    console.info("Raw date", rawDate);
    const parsedDate = moment(rawDate, format);
    return parsedDate;
  }
  protected override async extractContent(_page: Page): Promise<string | null> {
    return "";
  }
}
