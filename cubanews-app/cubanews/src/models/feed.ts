export enum NewsSourceName {
  ADNCUBA = "ADNCUBA",
  CATORCEYMEDIO = "CATORCEYMEDIO",
  DIARIODECUBA = "DIARIODECUBA",
  CIBERCUBA = "CIBERCUBA",
  ELTOQUE = "ELTOQUE",
  CUBANET = "CUBANET",
  ASERENOTICIAS = "ASERENOTICIAS",
  CUBANOSPORELMUNDO = "CUBANOSPORELMUNDO",
  DIRECTORIOCUBANO = "DIRECTORIOCUBANO",
  HAVANATIMES = "HAVANATIMES",
  MARTINOTICIAS = "MARTINOTICIAS",
  PERIODICOCUBANO = "PERIODICOCUBANO",
  CUBANOTICIAS360 = "CUBANOTICIAS360",
  unknown = "unknown",
}

export function parseNewsSourceName(value: unknown): NewsSourceName {
  if (typeof value !== "string") {
    return NewsSourceName.unknown;
  }

  const upper = value.toUpperCase();
  return (Object.values(NewsSourceName) as string[]).includes(upper)
    ? (upper as NewsSourceName)
    : NewsSourceName.unknown;
}

export function getNewsSourceDisplayName(source: NewsSourceName): string {
  switch (source) {
    case NewsSourceName.ADNCUBA:
      return "ADN Cuba";
    case NewsSourceName.CATORCEYMEDIO:
      return "14yMedio";
    case NewsSourceName.DIARIODECUBA:
      return "Diario De Cuba";
    case NewsSourceName.CIBERCUBA:
      return "Cibercuba";
    case NewsSourceName.ELTOQUE:
      return "el TOQUE";
    case NewsSourceName.CUBANET:
      return "Cubanet";
    case NewsSourceName.ASERENOTICIAS:
      return "Asere Noticias";
    case NewsSourceName.CUBANOSPORELMUNDO:
      return "Cubanos por el Mundo";
    case NewsSourceName.DIRECTORIOCUBANO:
      return "Directorio Cubano";
    case NewsSourceName.HAVANATIMES:
      return "Havana Times";
    case NewsSourceName.MARTINOTICIAS:
      return "Marti Noticias";
    case NewsSourceName.PERIODICOCUBANO:
      return "Periodico Cubano";
    case NewsSourceName.CUBANOTICIAS360:
      return "CubaNoticias360";
    case NewsSourceName.unknown:
      return "Unknown";
  }
}

export function getNewsSourceImageName(source: NewsSourceName): string {
  switch (source) {
    case NewsSourceName.ADNCUBA:
      return "adncuba";
    case NewsSourceName.CATORCEYMEDIO:
      return "catorceymedio";
    case NewsSourceName.DIARIODECUBA:
      return "ddc";
    case NewsSourceName.CIBERCUBA:
      return "cibercuba";
    case NewsSourceName.ELTOQUE:
      return "eltoque";
    case NewsSourceName.CUBANET:
      return "cubanet";
    case NewsSourceName.ASERENOTICIAS:
      return "aserenoticias";
    case NewsSourceName.CUBANOSPORELMUNDO:
      return "cubanosporelmundo";
    case NewsSourceName.DIRECTORIOCUBANO:
      return "directoriocubano";
    case NewsSourceName.HAVANATIMES:
      return "havanatimes";
    case NewsSourceName.MARTINOTICIAS:
      return "martinoticias";
    case NewsSourceName.PERIODICOCUBANO:
      return "periodicocubano";
    case NewsSourceName.CUBANOTICIAS360:
      return "cubanoticias360";
    case NewsSourceName.unknown:
      return "cubanewsIdentity";
  }
}

export interface InteractionData {
  feedid: number;
  likes?: number;
  comments?: number;
  shares?: number;
}

export enum ImageLoadingState {
  LOADING = "LOADING",
  LOADED = "LOADED",
  ERROR = "ERROR",
}

export interface FeedItem {
  id: number;
  title: string;
  url: string;
  source: NewsSourceName;
  updated: number;
  isoDate: string;
  feedts?: number;
  content?: string;
  tags: string[];
  score: number;
  interactions: InteractionData;
  aiSummary?: string;
  image?: string;
  imageBytes?: string;
  imageLoadingState: ImageLoadingState;
  saved: boolean;
}

export type FeedItemInput = Partial<FeedItem> &
  Pick<FeedItem, "id" | "title" | "url" | "source">;

function parseOptionalNumber(value: unknown): number | undefined {
  if (typeof value === "number") {
    return Number.isFinite(value) ? value : undefined;
  }

  if (typeof value === "string") {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : undefined;
  }

  return undefined;
}

export function createFeedItem(input: FeedItemInput): FeedItem {
  return {
    id: input.id,
    title: input.title,
    url: input.url,
    source: input.source,
    updated: input.updated ?? 0,
    isoDate: input.isoDate ?? "",
    feedts: input.feedts,
    content: input.content,
    tags: input.tags ?? [],
    score: input.score ?? 0,
    interactions: input.interactions ?? { feedid: 0 },
    aiSummary: input.aiSummary,
    image: input.image,
    imageBytes: input.imageBytes,
    imageLoadingState: input.imageLoadingState ?? ImageLoadingState.LOADING,
    saved: input.saved ?? false,
  };
}

export function parseFeedItem(payload: Record<string, unknown>): FeedItem {
  return createFeedItem({
    id: Number(payload.id ?? 0),
    title: String(payload.title ?? ""),
    url: String(payload.url ?? ""),
    source: parseNewsSourceName(payload.source),
    updated: parseOptionalNumber(payload.updated) ?? 0,
    isoDate: typeof payload.isoDate === "string" ? payload.isoDate : "",
    feedts: parseOptionalNumber(payload.feedts),
    content: typeof payload.content === "string" ? payload.content : undefined,
    tags: Array.isArray(payload.tags)
      ? payload.tags.filter((tag): tag is string => typeof tag === "string")
      : [],
    score: parseOptionalNumber(payload.score) ?? 0,
    interactions:
      payload.interactions && typeof payload.interactions === "object"
        ? {
            feedid:
              parseOptionalNumber(
                (payload.interactions as Record<string, unknown>).feedid,
              ) ?? 0,
            likes: parseOptionalNumber(
              (payload.interactions as Record<string, unknown>).likes,
            ),
            comments: parseOptionalNumber(
              (payload.interactions as Record<string, unknown>).comments,
            ),
            shares: parseOptionalNumber(
              (payload.interactions as Record<string, unknown>).shares,
            ),
          }
        : { feedid: 0 },
    aiSummary:
      typeof payload.aiSummary === "string" ? payload.aiSummary : undefined,
    image: typeof payload.image === "string" ? payload.image : undefined,
    imageBytes:
      typeof payload.imageBytes === "string" ? payload.imageBytes : undefined,
    imageLoadingState:
      typeof payload.imageLoadingState === "string" &&
      (Object.values(ImageLoadingState) as string[]).includes(
        payload.imageLoadingState,
      )
        ? (payload.imageLoadingState as ImageLoadingState)
        : ImageLoadingState.LOADING,
    saved: Boolean(payload.saved),
  });
}

export function removeDuplicateFeedItems(items: FeedItem[]): FeedItem[] {
  const seen = new Set<number>();
  return items.filter((item) => {
    if (seen.has(item.id)) {
      return false;
    }

    seen.add(item.id);
    return true;
  });
}
