// For more information, see https://crawlee.dev/

import { Actor } from "apify";
import ElToqueCrawler from "../node_modules/cubanews-crawler/dist/eltoqueCrawler.js";

try {
  await Actor.init();
  const dataset = await Actor.openDataset("eltoque-dataset");
  await dataset.drop();
  const crawler = new ElToqueCrawler();
  await crawler.runX();
} catch (err) {
  console.log(err);
} finally {
  await Actor.exit();
}
