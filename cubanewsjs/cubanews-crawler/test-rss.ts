import { NewsSource, NewsSourceName } from "./src/newsSource.js";
import { CubanewsRSSCrawler } from "./src/cubanewsRRSCrawler.js";

async function testRSS() {
  const sources = [
    {
      name: NewsSourceName.CATORCEYMEDIO,
      startUrls: new Set(["https://www.14ymedio.com/cuba"]),
      rssFeed: "https://www.14ymedio.com/rss/",
      datasetName: NewsSourceName.CATORCEYMEDIO + "-dataset",
    } as NewsSource,
    {
      name: NewsSourceName.DIRECTORIO_CUBANO,
      startUrls: new Set(),
      rssFeed: "https://www.directoriocubano.info/feed/",
      datasetName: NewsSourceName.DIRECTORIO_CUBANO + "-dataset",
    } as NewsSource,
  ];
  const crawler = new CubanewsRSSCrawler(sources);
  await crawler.getRSSContent(false);
}

testRSS().catch(console.error);
