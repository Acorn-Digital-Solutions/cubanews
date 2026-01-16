import CibercubaCrawler from "./src/cibercubaCrawler.js";

async function testRSS() {
  const crawler = new CibercubaCrawler();
  console.log("Crawler initialized:", crawler);
}

testRSS().catch(console.error);
