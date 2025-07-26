// For more information, see https://crawlee.dev/

import { Actor } from "apify";
import PeriodicoCubanoCrawler from "../node_modules/cubanews-crawler/dist/periodicoCubanoCrawler.js";
try {
  await Actor.init();
  const dataset = await Actor.openDataset("periodicocubano-dataset");
  await dataset.drop();
  const crawler = new PeriodicoCubanoCrawler();
  await crawler.runX();
} catch (err) {
  console.log(err);
} finally {
  await Actor.exit();
}
