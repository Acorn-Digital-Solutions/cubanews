import {
  FeedItem,
  ImageLoadingState,
  NewsSourceName,
} from "@/models/feed-model";

type ApiFeedItem = {
  id?: number;
  title?: string;
  url?: string;
  source?: NewsSourceName | string;
  updated?: number;
  isoDate?: string;
  iso_date?: string;
  feedts?: number | null;
  content?: string | null;
  tags?: string[];
  score?: number;
  interactions?: {
    feedid?: number;
    view?: number;
    like?: number;
    share?: number;
  };
  aiSummary?: string | null;
  ai_summary?: string | null;
  image?: string | null;
  imageLoadingState?: ImageLoadingState;
};

type ApiFeedResponseData = {
  content?: {
    feed?: ApiFeedItem[];
  };
};

type FetchFeedItemsParams = {
  page: number;
  pageSize: number;
  existingIds?: Set<number>;
  signal?: AbortSignal;
};

type FetchFeedItemsResult = {
  items: FeedItem[];
  allIds: Set<number>;
  hasNewItems: boolean;
};

export class FeedService {
  private readonly apiBaseUrl: string;

  constructor(
    apiBaseUrl: string = process.env.EXPO_PUBLIC_CUBANEWS_API ??
      "https://www.cubanews.icu/api",
  ) {
    this.apiBaseUrl = apiBaseUrl.trim().replace(/\/+$/, "");
  }

  async fetchFeedItems({
    page,
    pageSize,
    existingIds = new Set<number>(),
    signal,
  }: FetchFeedItemsParams): Promise<FetchFeedItemsResult> {

    const url = `${this.apiBaseUrl}/feed?page=${page}&pageSize=${pageSize}`;
    const response = await fetch(url, { method: "GET", redirect: "follow" });

    if (!response.ok) {
      throw new Error(`Failed to load feed. Status: ${response.status}`);
    }

    const decoded = (await response.json()) as ApiFeedResponseData;
    const feed = decoded.content?.feed ?? [];

    const normalizedItems = feed.map((rawItem) => this.toFeedItem(rawItem));
    const newItems = normalizedItems.filter(
      (item) => !existingIds.has(item.id),
    );
    const allIds = new Set(existingIds);
    newItems.forEach((item) => allIds.add(item.id));

    return {
      items: newItems,
      allIds,
      hasNewItems: newItems.length > 0,
    };
  }

  private toFeedItem(rawItem: ApiFeedItem): FeedItem {
    const id = Number(rawItem.id) || 0;
    return new FeedItem({
      id,
      title: rawItem.title ?? "",
      url: rawItem.url ?? "",
      source: this.toNewsSource(rawItem.source),
      updated: rawItem.updated ?? 0,
      isoDate: rawItem.isoDate ?? rawItem.iso_date ?? "",
      feedts: rawItem.feedts ?? null,
      content: rawItem.content ?? null,
      tags: rawItem.tags ?? [],
      score: rawItem.score ?? 0,
      interactions: {
        feedid: rawItem.interactions?.feedid ?? id,
        view: rawItem.interactions?.view ?? 0,
        like: rawItem.interactions?.like ?? 0,
        share: rawItem.interactions?.share ?? 0,
      },
      aiSummary: rawItem.aiSummary ?? rawItem.ai_summary ?? null,
      image: rawItem.image ?? null,
      imageBytes: null,
      imageLoadingState: rawItem.imageLoadingState ?? ImageLoadingState.LOADING,
    });
  }

  private toNewsSource(
    source: NewsSourceName | string | undefined,
  ): NewsSourceName {
    const normalized = String(source ?? "").toLowerCase();
    const validSources = Object.values(NewsSourceName) as string[];

    if (validSources.includes(normalized)) {
      return normalized as NewsSourceName;
    }

    return NewsSourceName.ADNCUBA;
  }
}

export type { FetchFeedItemsParams, FetchFeedItemsResult };
