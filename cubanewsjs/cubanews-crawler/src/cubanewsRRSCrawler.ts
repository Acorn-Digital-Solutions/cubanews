import Parser from "rss-parser";
import { RSSArticle } from "./rssArticle.js";
import {
  connectStorageEmulator,
  FirebaseStorage,
  getStorage,
  ref,
  uploadBytes,
} from "firebase/storage";
import { firebaseConfig } from "./firebaseConfig.js";
import { initializeApp } from "firebase/app";
import { NewsSource } from "./newsSource.js";

export class CubanewsRSSCrawler {
  protected newsSources: Array<NewsSource>;

  constructor(
    newsSources: Array<NewsSource>,
    private storage?: FirebaseStorage
  ) {
    this.newsSources = newsSources;
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

  async getRSSContent(uploadImages: boolean = true): Promise<RSSArticle[]> {
    try {
      // Configure parser to extract media fields from RSS
      const parser = new Parser({
        customFields: {
          item: [
            ["media:content", "media:content"],
            ["media:thumbnail", "media:thumbnail"],
          ],
        },
      });
      const articles: RSSArticle[] = [];
      for (const source of this.newsSources) {
        const feed = await parser.parseURL(source.rssFeed);
        // Get the latest 50 articles (or all if there are fewer than 50)
        const feedItems = feed.items.slice(0, 50);

        // Process each article
        for (const item of feedItems) {
          if (!item.link) {
            continue;
          }

          console.log("Processing Article:", item.link);

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
              const storagePath = `images/${source.name}/${imageName}`;
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
                error.message
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
      }
      return articles;
    } catch (error: any) {
      console.error("Error fetching RSS feed", { error: error.message });
      throw error;
    }
  }
}
