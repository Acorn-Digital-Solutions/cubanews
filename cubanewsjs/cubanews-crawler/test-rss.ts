import { NewsSource, NewsSourceName } from "./src/newsSource.js";
import { CubanewsRSSCrawler } from "./src/cubanewsRRSCrawler.js";

async function testRSS() {
  const source = {
    name: NewsSourceName.CATORCEYMEDIO,
    startUrls: new Set(["https://www.14ymedio.com/cuba"]),
    rssFeed: "https://www.14ymedio.com/rss/",
    datasetName: NewsSourceName.CATORCEYMEDIO + "-dataset",
    imageSelector:
      "div.bbnx-opening.single-column-default-width > figure > picture > source:nth-child(1)",
    cookiesConsentSelector: '[data-role="b_agree"]',
  } as NewsSource;
  const crawler = new CubanewsRSSCrawler(source);
  await crawler.getRSSContent(false, false);
}

testRSS().catch(console.error);
