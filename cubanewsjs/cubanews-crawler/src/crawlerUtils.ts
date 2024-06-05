export enum NewsSourceName {
  ADNCUBA = "adncuba",
  CATORCEYMEDIO = "catorceymedio",
  DIARIODECUBA = "diariodecuba",
  CIBERCUBA = "cibercuba",
  ELTOQUE = "eltoque",
  CUBANET = "cubanet",
}

export interface NewsSource {
  name: NewsSourceName;
  startUrls: Set<string>;
  datasetName: string;
}

export const newsSources = [
  {
    name: NewsSourceName.ADNCUBA,
    startUrls: new Set([
      "https://adncuba.com/",
      "https://adncuba.com/noticias-de-cuba/",
    ]),
    datasetName: NewsSourceName.ADNCUBA + "-dataset",
  },
  {
    name: NewsSourceName.CATORCEYMEDIO,
    startUrls: new Set(["https://www.14ymedio.com/cuba"]),
    datasetName: NewsSourceName.CATORCEYMEDIO + "-dataset",
  },
  {
    name: NewsSourceName.DIARIODECUBA,
    startUrls: new Set(["https://diariodecuba.com/"]),
    datasetName: NewsSourceName.DIARIODECUBA + "-dataset",
  },
  {
    name: NewsSourceName.CIBERCUBA,
    startUrls: new Set(["https://www.cibercuba.com/actualidad"]),
    datasetName: NewsSourceName.CIBERCUBA + "-dataset",
  },
  {
    name: NewsSourceName.ELTOQUE,
    startUrls: new Set(["https://eltoque.com/"]),
    datasetName: NewsSourceName.ELTOQUE + "-dataset",
  },
  {
    name: NewsSourceName.CUBANET,
    startUrls: new Set([
      "https://www.cubanet.org/",
      "https://www.cubanet.org/categoria/destacados/",
    ]),
    datasetName: NewsSourceName.CUBANET + "-dataset",
  },
];

export function getNewsSourceByName(source: NewsSourceName): NewsSource {
  const res = newsSources.filter((ns) => ns.name === source).shift();
  if (!res) {
    throw new Error(`News source ${source} not found`);
  }
  return res;
}
