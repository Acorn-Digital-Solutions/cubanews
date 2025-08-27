import {
  CrawlerRunOptions,
  Dataset,
  Dictionary,
  EnqueueLinksOptions,
  PlaywrightCrawler,
  PlaywrightCrawlingContext,
} from "crawlee";
import { NewsSource } from "./crawlerUtils.js";
import { Actor } from "apify";
import { Page } from "playwright";
import { Moment } from "moment";
import moment from "moment";
import path from "path";
import * as fs from "fs";

export interface ICubanewsCrawler {
  runX(): Promise<void>;
  requestHandlerX(context: PlaywrightCrawlingContext): Promise<void>;
}

export abstract class CubanewsCrawler
  extends PlaywrightCrawler
  implements ICubanewsCrawler
{
  protected newsSource: NewsSource;
  protected enqueueLinkOptions: EnqueueLinksOptions = {};

  constructor(newsSource: NewsSource) {
    super({
      requestHandler: (context) => {
        return this.requestHandlerX(context);
      },
      maxRequestsPerCrawl: 50,
    });
    this.newsSource = newsSource;
  }

  get datasetName(): string {
    return this.newsSource.name + "-dataset";
  }

  get startUrls(): Set<string> {
    return this.newsSource.startUrls;
  }

  protected abstract isUrlValid(url: string): boolean;
  protected abstract extractDate(page: Page): Promise<moment.Moment | null>;
  protected abstract extractContent(page: Page): Promise<string | null>;
  protected abstract imageSelector(): string;

  private async getMainImage(page: Page): Promise<string | null> {
    // Locate the <img> inside the <picture>
    const imageName = Math.floor(Math.random() * 1000000) + 1;
    const imageSelector = this.imageSelector();
    const img = page.locator(imageSelector);
    const imgUrl = await img.first().getAttribute("src");
    if (!imgUrl) {
      throw new Error("Image src not found");
    }
    // Resolve relative URLs against the page’s base URL
    const url = new URL(imgUrl, page.url()).toString();
    console.log("Image URL", url);
    // Fetch image bytes
    const response = await page.request.get(url);
    if (!response.ok()) {
      throw new Error(
        `Failed to download image: ${response.status()} ${response.statusText()}`
      );
    }
    const buffer = await response.body();
    // Save to local disk
    const outPath = path.resolve(".", `image-${imageName}.webp`);
    fs.writeFileSync(outPath, buffer);
    return outPath;
  }
  protected extractContentSummary(content: string): string {
    return content.trim().replace(/\n/g, "").split(" ").slice(0, 50).join(" ");
  }
  protected generateAiContentSummary(content: string): string {
    return content;
  }

  protected async parseTitle(page: Page): Promise<string | null> {
    const title = await page.title();
    if (!title) {
      return null;
    }
    return title.split("|")[0].trim();
  }

  /**
   * This is the most important function of the crawler.
   * It is called for each page that is loaded and parsed by the crawler.
   * It is passed the page object and the request object that was used to load it.
   * It is expected to enqueue new links to crawl and to save the extracted data.
   *
   * Any specific crawler logic can be achieved by implementing the abstract functions.
   *
   * As a general rule this function should not be overriden by the child crawlers.
   *
   * @param context The crawling context object.
   */
  async requestHandlerX(context: PlaywrightCrawlingContext): Promise<void> {
    const { page, request, enqueueLinks, log } = context;
    const title = await this.parseTitle(page);
    log.info(`Title of ${request.loadedUrl} is '${title}'`);

    // This condition guarantees that the content is extracted from pages that are real articles.
    // The home page, login and such should be filtered out.
    if (request.loadedUrl && this.isUrlValid(request.loadedUrl)) {
      const momentDate = await this.extractDate(page);
      if (momentDate && this.isValidDate(momentDate)) {
        var content = await this.extractContent(page);
        if (!content || content?.length < 100) {
          // This is to guarantee this is a real article.
          return;
        }
        content = this.extractContentSummary(content);
        const imagePath = await this.getMainImage(page);
        console.log("Image Path: " + imagePath);
        if (this.newsSource) {
          await this.saveData(
            {
              title,
              url: request.loadedUrl,
              updated: momentDate.unix(),
              isoDate: momentDate.toISOString(),
              content: content,
              source: this.newsSource.name,
              image: imagePath,
            },
            this.datasetName,
            process.env.NODE_ENV !== "dev"
          );
        }
      } else {
        if (!momentDate || !momentDate.isValid()) {
          log.error(`Could not extract date from ${request.loadedUrl}`);
        } else {
          log.warning(`Date is too old ${request.loadedUrl}`);
        }
      }
      const imagePath = await this.getMainImage(page);
      console.log("Image Path: " + imagePath);
    }

    // Extract links from the current page
    // and add them to the crawling queue.
    // Only enque links if we are in the start page. This is basically a depth=1 crawler.
    if (
      request.loadedUrl &&
      (this.startUrls.has(request.loadedUrl) ||
        this.startUrls.has(request.loadedUrl + "/"))
    ) {
      await enqueueLinks(this.enqueueLinkOptions);
    }
  }

  public async runX(options?: CrawlerRunOptions): Promise<void> {
    console.log(process.env.NODE_ENV);
    if (process.env.NODE_ENV === "dev") {
      await this.run([...this.startUrls], options);
    } else {
      const dataset = await Actor.openDataset(this.datasetName);
      await dataset.drop();
      await this.run([...this.startUrls]);
    }
  }

  private async saveData(
    data: Dictionary,
    datasetName: string,
    useActor: boolean = true
  ): Promise<void> {
    if (useActor) {
      const dataset = await Actor.openDataset(datasetName);
      await dataset.pushData(data);
    } else {
      await Dataset.pushData(data);
    }
  }

  private isValidDate(momentDate: Moment | null): boolean {
    if (momentDate && momentDate.toISOString()) {
      const now = moment();
      return now.diff(momentDate, "hours") < 72;
    }
    console.warn("Invalid Date.");
    return false;
  }
}
