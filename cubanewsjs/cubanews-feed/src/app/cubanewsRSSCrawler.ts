import Parser from "rss-parser";
import * as cheerio from "cheerio";
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

const imageStorageFolder = process.env.STORAGE_IMAGE_FOLDER ?? "images";

abstract class CubanewsRSSCrawler {
  protected newsSource: NewsSource;

  constructor(
    newsSource: NewsSource,
    private storage?: FirebaseStorage,
  ) {
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
        }`,
      );
    }
  }

  protected abstract tryGetMediaImage(item: any): string | null;

  private stripHtmlTags(html: string): string {
    if (!html) return "";
    // Remove HTML tags
    // Use cheerio to parse HTML and extract text content
    const $ = cheerio.load(html);
    return $.root().text().trim();
  }

  async getRSSContent(
    uploadImages: boolean = true,
    limit: number = 50,
  ): Promise<RSSArticle[]> {
    try {
      // Configure parser to extract media fields from RSS
      const parser = this.newsSource.parser;
      const articles: RSSArticle[] = [];

      // First, fetch the RSS feed to check what we're getting
      const response = await fetch(this.newsSource.rssFeed);

      if (!response.ok) {
        throw new Error(
          `Failed to fetch RSS feed from ${this.newsSource.name}: ${response.status} ${response.statusText}`,
        );
      }

      const contentType = response.headers.get("content-type");
      const responseText = await response.text();

      // Check if the response looks like XML
      if (
        !responseText.trim().startsWith("<?xml") &&
        !responseText.trim().startsWith("<rss") &&
        !responseText.trim().startsWith("<feed")
      ) {
        console.error(
          `Invalid RSS feed response from ${this.newsSource.name}. Content-Type: ${contentType}. First 200 chars:`,
          responseText.substring(0, 200),
        );
        throw new Error(
          `RSS feed from ${this.newsSource.name} returned non-XML content. This might be a blocked request or the feed URL has changed.`,
        );
      }

      const feed = await parser.parseString(responseText);
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
                `Failed to download image: ${response.status} ${response.statusText}`,
              );
            }
            const buffer = Buffer.from(await response.arrayBuffer());
            // Upload image buffer to Firebase Storage
            const storagePath = `${imageStorageFolder}/${this.newsSource.name}/${imageName}`;
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
            console.error(`Error processing image for ${item.link}:`, error);
          }
        }

        articles.push({
          title: item.title || "",
          link: item.link || "",
          pubDate: item.pubDate || "",
          author: item.creator || "",
          categories: item.categories || [],
          contentSnippet: this.stripHtmlTags(item.contentSnippet || ""),
          content: this.stripHtmlTags(item.content || ""),
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
      storage,
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
      storage,
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

export class DirectorioCubanoRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.DIRECTORIO_CUBANO,
        startUrls: new Set(["https://www.directoriocubano.info/"]),
        rssFeed: "https://www.directoriocubano.info/feed/",
        datasetName: NewsSourceName.DIRECTORIO_CUBANO + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["dc:creator", "creator"],
              ["content:encoded", "content"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Directorio Cubano embeds images in the description field as HTML
    let imageUrl: string | null = null;

    // Try description first (RSS standard), then content:encoded field
    const htmlContent = item.description || item.content || "";

    if (htmlContent) {
      // Extract image URL from HTML
      // Example: <img width="300" height="176" src="https://www.directoriocubano.info/wp-content/uploads/..." />
      const imgRegex = /<img[^>]+src="([^">]+)"/i;
      const match = htmlContent.match(imgRegex);
      if (match && match[1]) {
        imageUrl = match[1];
      }
    }

    return imageUrl;
  }
}

export class AdnCubaRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.ADNCUBA,
        startUrls: new Set(["https://adncuba.com/es"]),
        rssFeed: "https://adncuba.com/es/rss.xml",
        datasetName: NewsSourceName.ADNCUBA + "-dataset",
        parser: new Parser({
          customFields: {
            item: [["dc:creator", "creator"]],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // ADN Cuba RSS feed does not include images in the feed
    // Images would need to be scraped from the article page
    return null;
  }
}

export class MartiNoticiasRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.MARTI_NOTICIAS,
        startUrls: new Set(["https://www.martinoticias.com"]),
        rssFeed: "https://www.martinoticias.com/api/z_uqvl-vomx-tpevipt",
        datasetName: NewsSourceName.MARTI_NOTICIAS + "-dataset",
        parser: new Parser({
          customFields: {
            item: [],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Marti Noticias uses enclosure field for images
    if (item.enclosure?.url) {
      return item.enclosure.url;
    }
    return null;
  }
}

export class CubanosPorElMundoRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.CUBANOS_POR_EL_MUNDO,
        startUrls: new Set(["https://cubanosporelmundo.com"]),
        rssFeed: "http://cubanosporelmundo.com/feed/",
        datasetName: NewsSourceName.CUBANOS_POR_EL_MUNDO + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["media:content", "media:content"],
              ["media:thumbnail", "media:thumbnail"],
              ["dc:creator", "creator"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    return null;
  }
}

export class CubanetRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.CUBANET,
        startUrls: new Set(["https://www.cubanet.org"]),
        rssFeed: "https://www.cubanet.org/feed/",
        datasetName: NewsSourceName.CUBANET + "-dataset",
        parser: new Parser({
          customFields: {
            item: [["dc:creator", "creator"]],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Cubanet RSS feed does not include images in media fields
    // Try extracting from HTML description
    let imageUrl: string | null = null;

    const htmlContent = item.description || item.content || "";
    const imgRegex = /<img[^>]+src=["']([^"']+)["']/i;
    const match = htmlContent.match(imgRegex);
    if (match && match[1]) {
      imageUrl = match[1];
    }

    return imageUrl;
  }
}

export class AsereNoticiasRSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.ASERE_NOTICIAS,
        startUrls: new Set(["https://www.asere.com"]),
        rssFeed: "https://www.asere.com/feed/",
        datasetName: NewsSourceName.ASERE_NOTICIAS + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["media:content", "media:content"],
              ["media:thumbnail", "media:thumbnail"],
              ["dc:creator", "creator"],
              ["content:encoded", "content"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
          },
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Try to get image URL from RSS media fields or HTML content
    let imageUrl: string | null = null;

    // Try media:content first
    const mediaContent = (item as any)["media:content"];
    const mediaThumbnail = (item as any)["media:thumbnail"];

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
    } else {
      // Fallback: Try extracting from HTML description or content
      const htmlContent = item.description || item.content || "";
      const imgRegex = /<img[^>]+src=["']([^"']+)["']/i;
      const match = htmlContent.match(imgRegex);
      if (match && match[1]) {
        imageUrl = match[1];
      }
    }

    return imageUrl;
  }
}

export class CubaNoticias360RSSCrawler extends CubanewsRSSCrawler {
  constructor(storage?: FirebaseStorage) {
    super(
      {
        name: NewsSourceName.CUBANOTICIAS360,
        startUrls: new Set(["https://cubanoticias360.com"]),
        rssFeed: "https://cubanoticias360.com/feed",
        datasetName: NewsSourceName.CUBANOTICIAS360 + "-dataset",
        parser: new Parser({
          customFields: {
            item: [
              ["media:content", "media:content"],
              ["media:thumbnail", "media:thumbnail"],
              ["dc:creator", "creator"],
              ["content:encoded", "content"],
            ],
          },
          headers: {
            "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
            Accept: "application/rss+xml, application/xml, text/xml, */*",
            "Accept-Language": "en-US,en;q=0.9,es;q=0.8",
            "Accept-Encoding": "gzip, deflate, br",
            Referer: "https://cubanoticias360.com/",
            "Cache-Control": "no-cache",
            Pragma: "no-cache",
            DNT: "1",
            Connection: "keep-alive",
            "Upgrade-Insecure-Requests": "1",
          },
          timeout: 30000,
        }),
      },
      storage,
    );
  }

  override tryGetMediaImage(item: any): string | null {
    // Try to get image URL from RSS media fields or HTML content
    let imageUrl: string | null = null;

    // Try media:content first
    const mediaContent = (item as any)["media:content"];
    const mediaThumbnail = (item as any)["media:thumbnail"];

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
    } else {
      // Fallback: Try extracting from HTML description or content
      const htmlContent = item.description || item.content || "";
      const imgRegex = /<img[^>]+src=["']([^"']+)["']/i;
      const match = htmlContent.match(imgRegex);
      if (match && match[1]) {
        imageUrl = match[1];
      }
    }

    return imageUrl;
  }
}
