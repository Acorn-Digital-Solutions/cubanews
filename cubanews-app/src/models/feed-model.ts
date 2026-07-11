export enum NewsSourceName {
  ADNCUBA = "adncuba",
  ASERENOTICIAS = "aserenoticias",
  CATORCEYMEDIO = "catorceymedio",
  CIBERCUBA = "cibercuba",
  CUBANET = "cubanet",
  CUBANOSPORELMUNDO = "cubanosporelmundo",
  CUBANOTICIAS360 = "cubanoticias360",
  DIARIODECUBA = "diariodecuba",
  directoriocubano = "directoriocubano",
  ELTOQUE = "eltoque",
  HAVANATIMES = "havanatimes",
  MARTINOTICIAS = "martinoticias",
  PERIODICOCUBANO = "periodicocubano",
}

export interface InteractionData {
  feedid: number;
  view?: number;
  like?: number;
  share?: number;
}

export enum InteractionType {
  VIEW = "VIEW",
  LIKE = "LIKE",
  SHARE = "SHARE",
}

export enum ImageLoadingState {
  LOADING = "LOADING",
  LOADED = "LOADED",
  FAILED = "FAILED",
}

export class FeedItem {
  id: number;
  title: string;
  url: string;
  source: NewsSourceName;
  updated: number;
  isoDate: string;
  feedts: number | null;
  content: string | null;
  tags: string[];
  score: number;
  interactions: InteractionData;
  aiSummary: string | null;
  image: string | null;
  imageBytes: Uint8Array | null;
  imageLoadingState: ImageLoadingState;

  constructor(data: {
    id: number;
    title: string;
    url: string;
    source: NewsSourceName;
    updated?: number;
    isoDate?: string;
    feedts?: number | null;
    content?: string | null;
    tags?: string[];
    score?: number;
    interactions?: InteractionData;
    aiSummary?: string | null;
    image?: string | null;
    imageBytes?: Uint8Array | null;
    imageLoadingState?: ImageLoadingState;
  }) {
    this.id = data.id;
    this.title = data.title;
    this.url = data.url;
    this.source = data.source;
    this.updated = data.updated ?? 0;
    this.isoDate = data.isoDate ?? "";
    this.feedts = data.feedts ?? null;
    this.content = data.content ?? null;
    this.tags = data.tags ?? [];
    this.score = data.score ?? 0;
    this.interactions = data.interactions ?? {
      feedid: 0,
      view: 0,
      like: 0,
      share: 0,
    };
    this.aiSummary = data.aiSummary ?? null;
    this.image = data.image ?? null;
    this.imageBytes = data.imageBytes ?? null;
    this.imageLoadingState =
      data.imageLoadingState ?? ImageLoadingState.LOADING;
  }
}

export interface FeedContent {
  feed?: FeedItem[];
}

export interface FeedResponseData {
  content?: FeedContent;
}
