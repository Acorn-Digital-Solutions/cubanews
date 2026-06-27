import { FeedItem } from "@/models/feed";

class FeedService {
  private readonly baseUrl = "https://www.cubanews.icu/api/feed";

  public async getFeed(page: number, pageSize: number): Promise<FeedItem[]> {
    const response = await fetch(
      `${this.baseUrl}?page=${page}&pageSize=${pageSize}`,
    );
    if (!response.ok) {
      throw new Error(`Failed to fetch feed: ${response.statusText}`);
    }
    const data = await response.json();
    return data.map((item: any) => this.transformFeedItem(item));
  }

  private transformFeedItem(item: any): FeedItem {
    // Implement the transformation logic here
    return item as FeedItem;
  }
}
