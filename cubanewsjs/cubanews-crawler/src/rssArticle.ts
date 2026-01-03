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
