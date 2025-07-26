// For more information, see https://crawlee.dev/

import { Actor } from "apify";
import { NewsSourceName, getNewsSourceByName } from "./crawlerUtils.js";
import AdnCubaCrawler from "./adncubaCrawler.js";
import CibercubaCrawler from "./cibercubaCrawler.js";
import DiarioDeCubaCrawler from "./diarioDeCubaCrawler.js";
import CatorceYMedioCrawler from "./catorceYMedioCrawler.js";
import ElToqueCrawler from "./eltoqueCrawler.js";
import CubanetCrawler from "./cubanetCrawler.js";

try {
  await Actor.init();
  const x = await Actor.getInput();
  const { source } = (await Actor.getInput()) as { source: NewsSourceName };
  const newsSource = getNewsSourceByName(source);
  if (newsSource) {
    var crawler = null;
    switch (newsSource.name) {
      case NewsSourceName.ADNCUBA:
        crawler = new AdnCubaCrawler();
        break;
      case NewsSourceName.CIBERCUBA:
        crawler = new CibercubaCrawler();
        break;
      case NewsSourceName.DIARIODECUBA:
        crawler = new DiarioDeCubaCrawler();
        break;
      case NewsSourceName.CATORCEYMEDIO:
        crawler = new CatorceYMedioCrawler();
        break;
      case NewsSourceName.ELTOQUE:
        crawler = new ElToqueCrawler();
        break;
      case NewsSourceName.CUBANET:
        crawler = new CubanetCrawler();
        break;
      case NewsSourceName.PERIODICO_CUBANO:
        crawler = new DiarioDeCubaCrawler();
        break;
      default:
        throw new Error("Invalid news source");
    }
    await crawler.runX();
  }
} catch (err) {
  console.log(err);
} finally {
  await Actor.exit();
}
