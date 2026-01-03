import Parser from "rss-parser";
import { RSSArticle } from "./rssArticle.js";
import { chromium } from "playwright";
import {
  connectStorageEmulator,
  FirebaseStorage,
  getStorage,
  ref,
  uploadBytes,
} from "firebase/storage";
import { firebaseConfig } from "./firebaseConfig.js";
import { initializeApp } from "firebase/app";
import { NewsSource } from "./crawlerUtils.js";

export class CubanewsRSSCrawler {
  protected newsSource: NewsSource;

  constructor(newsSource: NewsSource, private storage?: FirebaseStorage) {
    this.newsSource = newsSource;
    if (!storage) {
      const firebaseApp = initializeApp(firebaseConfig);
      this.storage = getStorage(firebaseApp);
      if (process.env.FIREBASE_EMULATOR === "true") {
        connectStorageEmulator(this.storage, "localhost", 9199);
      }
      console.info(
        `Storage Bucket: ${
          this.storage.app.options.storageBucket?.toString() ?? "<ERROR>"
        }`
      );
    }
  }

  private async dismissCookiesConsent(page: any): Promise<void> {
    if (this.newsSource.cookiesConsentSelector) {
      try {
        const consentButton = page.locator(
          this.newsSource.cookiesConsentSelector
        );
        if (await consentButton.count()) {
          await consentButton.first().click();
          console.info("Cookies consent dismissed.");
        }
      } catch (error: any) {
        console.error("Error dismissing cookies consent:", error.message);
      }
    }
  }

  async getRSSContent(
    headless: boolean = true,
    uploadImages: boolean = true
  ): Promise<RSSArticle[]> {
    if (!this.newsSource.rssFeed) {
      return [];
    }
    try {
      const parser = new Parser();
      const feed = await parser.parseURL(this.newsSource.rssFeed);

      // Get the latest 50 articles (or all if there are fewer than 50)
      const feedItems = feed.items.slice(0, 50);
      const articles: RSSArticle[] = [];

      let browser = await chromium.launch({
        headless: headless,
        slowMo: headless ? 0 : 100, // Slow down actions when visible for easier viewing
      });

      const context = await browser.newContext({
        viewport: { width: 1280, height: 720 },
        userAgent:
          "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
      });
      const page = await context.newPage();
      const imageSelector = this.newsSource.imageSelector ?? "";

      // Process each article and fetch its main image
      for (const item of feedItems) {
        if (!item.link) {
          continue;
        }
        console.log("Navigating to Article:", item.link);
        await page.goto(item.link || "", {
          waitUntil: "load",
          timeout: 30000,
        });
        await this.dismissCookiesConsent(page);
        let imageUrl = await page
          .locator(imageSelector)
          .first()
          .getAttribute("src");
        if (!imageUrl) {
          imageUrl = await page
            .locator(imageSelector)
            .first()
            .getAttribute("srcset");
        }
        let imagePath: string | null = null;
        if (imageUrl) {
          // Resolve relative URLs against the page’s base URL
          const imageName = Math.floor(Math.random() * 1000000) + 1;
          const url = new URL(imageUrl, page.url()).toString();
          console.info("Image URL", { url: url });
          // Fetch image bytes
          const response = await page.request.get(url);

          const buffer = await response.body();
          // Upload image buffer to Firebase Storage
          const storagePath = `images/${this.newsSource.name}/${imageName}`;
          if (!this.storage) {
            throw new Error("Firebase storage is not initialized.");
          }
          const storageRef = ref(this.storage, storagePath);
          if (uploadImages) {
            const uploadResult = await uploadBytes(storageRef, buffer)
              .then((result) => {
                console.info(result.metadata.fullPath);
                return result;
              })
              .catch((reason) => {
                console.error(reason);
                throw reason;
              });
            console.info(`Image uploaded to ${uploadResult.ref.fullPath}`);
            console.info(uploadResult.ref.fullPath);
          }

          // Get public URL
          imagePath = `gs://cubanews-fbaad.firebasestorage.app/${storagePath}`;
        }

        articles.push({
          title: item.title || "",
          link: item.link || "",
          pubDate: item.pubDate || "",
          author: item.creator || item.author || "",
          categories: item.categories || [],
          contentSnippet: item.contentSnippet || "",
          content: item.content || "",
          guid: item.guid || "",
          isoDate: item.isoDate || "",
          image: imagePath,
        });
      }
      console.log(JSON.stringify(articles, null, 2));
      await browser.close();
      return articles;
    } catch (error: any) {
      console.error("Error fetching RSS feed", { error: error.message });
      throw error;
    }
  }
}
