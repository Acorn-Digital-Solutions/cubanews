import "server-only";

import {
  Interaction,
  InteractionData,
  InteractionResponseData,
} from "@/app/interfaces";
import { NextRequest, NextResponse } from "next/server";
import cubanewsApp from "@/app/cubanewsApp";

const db = cubanewsApp.getDatabase;

export async function POST(
  request: NextRequest
): Promise<NextResponse<InteractionResponseData | null>> {
  const { feedid, interaction } = await request.json();
  if (!feedid) {
    return NextResponse.json(
      {
        banter: "feedid cannot be null",
      },
      { status: 400, statusText: "Bad Parameters" }
    );
  }
  if (!interaction) {
    return NextResponse.json(
      {
        banter: "interaction cannot be null",
      },
      { status: 400, statusText: "Bad Parameters" }
    );
  }
  db.insertInto("interactions")
    .values([
      {
        feedid: parseInt(feedid), // Replace with the actual feedid
        interaction: interaction, // Replace with the actual interaction type
        timestamp: Date.now(), // Current timestamp
      },
    ])
    .execute();

  const interactions = await db
    .selectFrom("interactions")
    .select(["interaction", db.fn.count("id").as("count")])
    .where("feedid", "=", parseInt(feedid))
    .groupBy("interaction")
    .execute();

  console.log(interactions);
  const content = {
    like: 0,
    view: 0,
    share: 0,
  } as InteractionData;
  interactions.forEach((x) => {
    const action: Interaction = x.interaction;
    content[action] = x.count as number;
  });

  return NextResponse.json(
    {
      banter: "Refreshing cubanews feed",
      content: content,
    },
    { status: 200 }
  );
}

export async function GET(
  request: NextRequest
): Promise<NextResponse<InteractionResponseData | null>> {
  const feedid = request.nextUrl.searchParams.get("feedid");
  if (!feedid) {
    return NextResponse.json(
      {
        banter: "feedid cannot be null",
      },
      { status: 400, statusText: "Bad Parameters" }
    );
  }

  const interactions = await db
    .selectFrom("interactions")
    .select(["interaction", db.fn.count("id").as("count")])
    .where("feedid", "=", parseInt(feedid))
    .groupBy("interaction")
    .execute();

  const content = {
    like: 0,
    view: 0,
    share: 0,
  } as InteractionData;
  interactions.forEach((x) => {
    const action: Interaction = x.interaction;
    content[action] = x.count as number;
  });

  return NextResponse.json(
    {
      banter: "Refreshing cubanews feed",
      content: content,
    },
    { status: 200 }
  );
}
