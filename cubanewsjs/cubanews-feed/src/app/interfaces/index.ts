import Parser from "rss-parser";

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
  aiSummary: string;
  image: string;
};

export type NewsFeed = {
  timestamp: number | null | undefined;
  feed: Array<NewsItem>;
};

export type FeedResponseData = {
  banter: string;
  content?: NewsFeed;
};

export type ImageResponseData = {
  content?: ArrayBuffer;
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
  PERIODICO_CUBANO = "periodicocubano",
  DIRECTORIO_CUBANO = "directoriocubano",
  MARTI_NOTICIAS = "martinoticias",
  CUBANOS_POR_EL_MUNDO = "cubanosporelmundo",
}

export enum NewsSourceDisplayName {
  ADNCUBA = "AdnCuba",
  CATORCEYMEDIO = "14yMedio",
  DIARIODECUBA = "Diario de Cuba",
  CIBERCUBA = "Cibercuba",
  ELTOQUE = "elToque",
  CUBANET = "Cubanet",
  PERIODICO_CUBANO = "Periódico Cubano",
  DIRECTORIO_CUBANO = "Directorio Cubano",
  MARTI_NOTICIAS = "Martí Noticias",
  CUBANOS_POR_EL_MUNDO = "Cubanos por el Mundo",
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
  item: NewsItem,
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
    case NewsSourceName.PERIODICO_CUBANO:
      return NewsSourceDisplayName.PERIODICO_CUBANO;
    case NewsSourceName.DIRECTORIO_CUBANO:
      return NewsSourceDisplayName.DIRECTORIO_CUBANO;
    default:
      return NewsSourceDisplayName.EMPTY;
  }
}

export type ResolveNewsletterSubscriptionData = {
  operation: "subscribe" | "close";
  email: string;
  dontShowAgain: boolean;
};

export interface RSSArticle {
  title: string;
  link: string;
  pubDate: string;
  author: string;
  categories: string[];
  contentSnippet: string;
  content: string;
  guid: string;
  isoDate: string;
  image: string | null;
}

export interface NewsSource {
  name: NewsSourceName;
  startUrls: Set<string>;
  rssFeed: string;
  datasetName: string;
  parser: Parser;
}
