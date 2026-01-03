export enum NewsSourceName {
  ADNCUBA = "adncuba",
  CATORCEYMEDIO = "catorceymedio",
  DIARIODECUBA = "diariodecuba",
  CIBERCUBA = "cibercuba",
  ELTOQUE = "eltoque",
  CUBANET = "cubanet",
  PERIODICO_CUBANO = "periodicocubano",
}

export interface NewsSource {
  name: NewsSourceName;
  startUrls: Set<string>;
  rssFeed?: string;
  datasetName: string;
  imageSelector?: string;
  cookiesConsentSelector?: string;
}
