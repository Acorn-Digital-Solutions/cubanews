import {
  CatorceYMedioRSSCrawler,
  CibercubaRSSCrawler,
} from "./src/cubanewsRRSCrawler.js";

async function testRSS() {
  const crawler = new CibercubaRSSCrawler();
  await crawler.getRSSContent(false);
}

testRSS().catch(console.error);
