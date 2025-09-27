import { Generated } from "kysely";
import { Interaction } from "../interfaces";

export interface FeedTable {
  id: Generated<number>;
  feedts: number;
  feedisodate: string;
  source: string;
  title: string;
  url: string;
  content: string;
  updated: number; // This is the news item updated field.
  isodate: string;
  tags: string;
  score: number;
  imageurl: string;
}

export interface InteractionsTable {
  id: Generated<number>;
  feedid: number; // FK to feed table id.
  interaction: Interaction;
  timestamp: number;
}

export interface SubscriptionsTable {
  id: Generated<number>;
  email: string;
  status: string;
  timestamp: number;
}

export interface Database {
  feed: FeedTable;
  interactions: InteractionsTable;
  subscriptions: SubscriptionsTable;
}
