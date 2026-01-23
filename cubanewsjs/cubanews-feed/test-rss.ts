import {
  AdnCubaRSSCrawler,
  CatorceYMedioRSSCrawler,
  CibercubaRSSCrawler,
  CubanetRSSCrawler,
  CubanosPorElMundoRSSCrawler,
  DirectorioCubanoRSSCrawler,
  MartiNoticiasRSSCrawler,
} from "@/app/cubanewsRSSCrawler";

// Configuration
const CRAWLER_TO_TEST = process.env.CRAWLER_TO_TEST ?? "all"; // Options: "catorce", "cibercuba", "directorio", "adncuba", "marti", "cubanos", "cubanet", "all"
const UPLOAD_IMAGES = false; // Set to false for testing without Firebase uploads
const ARTICLE_LIMIT = 5; // Number of articles to fetch

async function testSingleCrawler(
  crawler: any,
  crawlerName: string,
): Promise<void> {
  console.log(`\n${"=".repeat(60)}`);
  console.log(`Testing: ${crawlerName}`);
  console.log(`RSS Feed: ${crawler.newsSource.rssFeed}`);
  console.log(`${"=".repeat(60)}\n`);

  try {
    const startTime = Date.now();
    const articles = await crawler.getRSSContent(UPLOAD_IMAGES, ARTICLE_LIMIT);
    const duration = ((Date.now() - startTime) / 1000).toFixed(2);

    console.log(`\n${"─".repeat(60)}`);
    console.log(
      `✓ SUCCESS: Fetched ${articles.length} articles in ${duration}s`,
    );
    console.log(`${"─".repeat(60)}\n`);

    // Summary statistics
    const withImages = articles.filter((a: any) => a.image).length;
    const withContent = articles.filter((a: any) => a.content).length;
    const withAuthor = articles.filter((a: any) => a.author).length;

    console.log("📊 Statistics:");
    console.log(`   Articles with images: ${withImages}/${articles.length}`);
    console.log(`   Articles with content: ${withContent}/${articles.length}`);
    console.log(`   Articles with author: ${withAuthor}/${articles.length}`);

    // Show sample article
    if (articles.length > 0) {
      console.log(`\n📰 Sample Article (first):`);
      console.log(`   Title: ${articles[0].title}`);
      console.log(`   Link: ${articles[0].link}`);
      console.log(`   Date: ${articles[0].pubDate}`);
      console.log(`   Author: ${articles[0].author || "N/A"}`);
      console.log(`   Image: ${articles[0].image || "NO IMAGE"}`);
      console.log(
        `   Categories: ${articles[0].categories?.slice(0, 3).join(", ") || "None"}`,
      );
      console.log(
        `   Content Length: ${articles[0].content?.length || 0} chars`,
      );
    }

    // Full output (optional)
    if (process.env.VERBOSE === "true") {
      console.log("\n📋 Full Article Data:");
      console.log(JSON.stringify(articles, null, 2));
    }
  } catch (error: any) {
    console.error(`\n✗ ERROR testing ${crawlerName}:`);
    console.error(`   Message: ${error.message}`);
    console.error(`   Stack: ${error.stack}`);
    throw error;
  }
}

async function testAllCrawlers(): Promise<void> {
  const crawlers = [
    { instance: new CatorceYMedioRSSCrawler(), name: "14yMedio" },
    { instance: new CibercubaRSSCrawler(), name: "Cibercuba" },
    { instance: new DirectorioCubanoRSSCrawler(), name: "Directorio Cubano" },
    { instance: new AdnCubaRSSCrawler(), name: "ADN Cuba" },
    { instance: new MartiNoticiasRSSCrawler(), name: "Martí Noticias" },
    {
      instance: new CubanosPorElMundoRSSCrawler(),
      name: "Cubanos por el Mundo",
    },
    { instance: new CubanetRSSCrawler(), name: "Cubanet" },
  ];

  for (const { instance, name } of crawlers) {
    await testSingleCrawler(instance, name);
  }
}

async function testRSS() {
  console.log("🚀 RSS Crawler Test Suite");
  console.log(`Upload Images: ${UPLOAD_IMAGES}`);
  console.log(`Article Limit: ${ARTICLE_LIMIT}`);

  try {
    if (CRAWLER_TO_TEST === "all") {
      await testAllCrawlers();
    } else {
      let crawler: any;
      let name: string;

      switch (CRAWLER_TO_TEST) {
        case "catorce":
          crawler = new CatorceYMedioRSSCrawler();
          name = "14yMedio";
          break;
        case "cibercuba":
          crawler = new CibercubaRSSCrawler();
          name = "Cibercuba";
          break;
        case "directorio":
          crawler = new DirectorioCubanoRSSCrawler();
          name = "Directorio Cubano";
          break;
        case "adncuba":
          crawler = new AdnCubaRSSCrawler();
          name = "ADN Cuba";
          break;
        case "marti":
          crawler = new MartiNoticiasRSSCrawler();
          name = "Martí Noticias";
          break;
        case "cubanos":
          crawler = new CubanosPorElMundoRSSCrawler();
          name = "Cubanos por el Mundo";
          break;
        case "cubanet":
          crawler = new CubanetRSSCrawler();
          name = "Cubanet";
          break;
        default:
          throw new Error(
            `Unknown crawler: ${CRAWLER_TO_TEST}. Use: catorce, cibercuba, directorio, adncuba, marti, cubanos, cubanet, or all`,
          );
      }

      await testSingleCrawler(crawler, name);
    }

    console.log("\n✅ All tests completed successfully!");
  } catch (error) {
    console.error("\n❌ Test suite failed!");
    process.exit(1);
  }
}

testRSS().catch(console.error);
