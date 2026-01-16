import Parser from "rss-parser";
import {
  connectStorageEmulator,
  FirebaseStorage,
  getStorage,
  ref,
  uploadBytes,
} from "firebase/storage";
import { initializeApp } from "firebase/app";
import { NewsSource, RSSArticle, NewsSourceName } from "./interfaces";
import { firebaseConfig } from "./interfaces/firebaseConfig";

abstract class CubanewsRSSCrawler {
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

  protected abstract tryGetMediaImage(item: any): string | null;

  async getRSSContent(
    uploadImages: boolean = true,
    limit: number = 50
  ): Promise<RSSArticle[]> {
    try {
      // Configure parser to extract media fields from RSS
      const parser = this.newsSource.parser;
      const articles: RSSArticle[] = [];

      const feed = await parser.parseURL(this.newsSource.rssFeed);
      // Get the latest 50 articles (or all if there are fewer than 50)
      const feedItems = feed.items.slice(0, limit);

      // Process each article
      for (const item of feedItems) {
        if (!item.link) {
          continue;
        }
        console.log("Processing Article:", item.link);
        // Try to get image URL from RSS media fields
        let imageUrl = this.tryGetMediaImage(item);

        let imagePath: string | null = null;
        if (imageUrl) {
          try {
            // Download and upload the image
            const imageName = Math.floor(Math.random() * 1000000) + 1;
            console.info("Image URL from RSS:", imageUrl);

            // Fetch image bytes using native fetch
            const response = await fetch(imageUrl);
            if (!response.ok) {
              throw new Error(
                `Failed to download image: ${response.status} ${response.statusText}`
              );
            }
            const buffer = Buffer.from(await response.arrayBuffer());
            // Upload image buffer to Firebase Storage
            const storagePath = `images/${this.newsSource.name}/${imageName}`;
            if (!this.storage) {
              throw new Error("Firebase storage is not initialized.");
            }
            const storageRef = ref(this.storage, storagePath);
            if (uploadImages) {
              const uploadResult = await uploadBytes(storageRef, buffer);
              console.info(`Image uploaded to ${uploadResult.ref.fullPath}`);
            }
            // Get public URL
            imagePath = `gs://cubanews-fbaad.firebasestorage.app/${storagePath}`;
          } catch (error: any) {
            console.error(
              `Error processing image for ${item.link}:`,
              error
            );
          }
        }

        articles.push({
          title: item.title || "",
          link: item.link || "",
          pubDate: item.pubDate || "",
          author: item.creator || "",
          categories: item.categories || [],
          contentSnippet: item.contentSnippet || "",
          content: item.content || "",
          guid: item.guid || "",
          isoDate: item.isoDate || "",
          image: imagePath,
        });
      }
      console.log(JSON.stringify(articles, null, 2));
      return articles;
    } catch (error: any) {
      console.error("Error fetching RSS feed:", error);
      throw error;
    }
  }
}

export class CatorceYMedioRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.CATORCEYMEDIO,
        startUrls: new Set(["https://www.14ymedio.com/cuba"]),
        rssFeed: "https://www.14ymedio.com/rss/",
        datasetName: NewsSourceName.CATORCEYMEDIO + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["media:content", "media:content"],
              ["media:thumbnail", "media:thumbnail"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Try to get image URL from RSS media fields
    let imageUrl: string | null = null;
    const mediaContent = (item as any)["media:content"];
    const mediaThumbnail = (item as any)["media:thumbnail"];

    // Extract URL from media:content or media:thumbnail
    if (
      mediaContent &&
      typeof mediaContent === "object" &&
      mediaContent.$?.url
    ) {
      imageUrl = mediaContent.$.url;
    } else if (
      mediaThumbnail &&
      typeof mediaThumbnail === "object" &&
      mediaThumbnail.$?.url
    ) {
      imageUrl = mediaThumbnail.$.url;
    }
    return imageUrl;
  }
}

export class CibercubaRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.CIBERCUBA,
        startUrls: new Set(["https://www.cibercuba.com/"]),
        rssFeed: "https://www.cibercuba.com/noticias/cibercuba/rss.xml",
        datasetName: NewsSourceName.CIBERCUBA + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["media:content", "media:content"],
              ["media:thumbnail", "media:thumbnail"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Try to get image URL from RSS enclosure field
    let imageUrl: string | null = null;
    // Check for enclosure field (Cibercuba uses this)
    if (
      item.enclosure &&
      typeof item.enclosure === "object" &&
      item.enclosure.url
    ) {
      imageUrl = item.enclosure.url;
    }
    return imageUrl;
  }
}
