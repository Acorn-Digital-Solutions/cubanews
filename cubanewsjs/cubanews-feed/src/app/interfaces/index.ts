export type ResponseError = {
  message: string;
};

export type NewsItem = {
  id: number;
  title: string;
  source: NewsSourceName;
  url: string;
  updated: number;
  isoDate: string;
  feedts: number | null | undefined;
  content: string | null | undefined;
  tags: Array<string>;
  score: number;
  interactions: InteractionData;
};

export type NewsFeed = {
  timestamp: number | null | undefined;
  feed: Array<NewsItem>;
};

export type FeedResponseData = {
  banter: string;
  content?: NewsFeed;
};

export type InteractionData = {
  feedid: number;
  view: number;
  like: number;
  share: number;
};

export type InteractionResponseData = {
  banter: string;
  content?: InteractionData;
};

export enum NewsSourceName {
  ADNCUBA = "adncuba",
  CATORCEYMEDIO = "catorceymedio",
  DIARIODECUBA = "diariodecuba",
  CIBERCUBA = "cibercuba",
  ELTOQUE = "eltoque",
  CUBANET = "cubanet",
}

export enum NewsSourceDisplayName {
  ADNCUBA = "AdnCuba",
  CATORCEYMEDIO = "14yMedio",
  DIARIODECUBA = "Diario de Cuba",
  CIBERCUBA = "Cibercuba",
  ELTOQUE = "elToque",
  CUBANET = "Cubanet",
  EMPTY = "",
}

export enum Interaction {
  VIEW = "view",
  LIKE = "like",
  SHARE = "share",
}

export enum SubscriptionStatus {
  SUBSCRIBED = "subscribed",
  UNSUBSCRIBED = "unsubscribed",
  NOTFOUND = "notfound",
}

export function getNewsSourceDisplayName(
  item: NewsItem
): NewsSourceDisplayName {
  switch (item.source) {
    case NewsSourceName.ADNCUBA:
      return NewsSourceDisplayName.ADNCUBA;
    case NewsSourceName.CATORCEYMEDIO:
      return NewsSourceDisplayName.CATORCEYMEDIO;
    case NewsSourceName.CIBERCUBA:
      return NewsSourceDisplayName.CIBERCUBA;
    case NewsSourceName.DIARIODECUBA:
      return NewsSourceDisplayName.DIARIODECUBA;
    case NewsSourceName.ELTOQUE:
      return NewsSourceDisplayName.ELTOQUE;
    case NewsSourceName.CUBANET:
      return NewsSourceDisplayName.CUBANET;
    default:
      return NewsSourceDisplayName.EMPTY;
  }
}

export type ResolveNewsletterSubscriptionData = {
  operation: "subscribe" | "close";
  email: string;
  dontShowAgain: boolean;
};
