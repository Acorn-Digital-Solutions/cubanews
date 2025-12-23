import { NextRequest, NextResponse } from "next/server";
import { SubscriptionStatus } from "@/app/interfaces";
import cubanewsApp from "@/app/cubanewsApp";
import { ok } from "assert";
import { getLogger } from "nodemailer/lib/shared";

interface SubscribeResponse {
  banter: string;
  constent?: {
    email: string;
    status: SubscriptionStatus;
  };
}

const db = cubanewsApp.getDatabase;

export async function POST(
  request: NextRequest
): Promise<NextResponse<SubscribeResponse>> {
  const { email, operation } = await request.json();
  if (!email || !operation) {
    return NextResponse.json(
      {
        banter:
          "Invalid email or operation. Supported opperations are subscribe, unsubscribe",
      },
      { status: 400, statusText: "Bad Parameters" }
    );
  }

  if (operation === "delete") {
  }

  const status =
    operation === "subscribe"
      ? SubscriptionStatus.SUBSCRIBED
      : SubscriptionStatus.UNSUBSCRIBED;
  await db
    .insertInto("subscriptions")
    .values({
      email: email,
      timestamp: Date.now(),
      status: status,
    })
    .execute();

  return NextResponse.json({
    banter: "All good",
    content: { email, status },
  });
}

export async function GET(
  request: NextRequest
): Promise<NextResponse<SubscribeResponse>> {
  const email = request.nextUrl.searchParams.get("email");

  const entry = await db
    .selectFrom("subscriptions")
    .selectAll()
    .where("email", "=", email)
    .orderBy("timestamp", "desc")
    .executeTakeFirst();

  if (!entry) {
    return NextResponse.json({
      banter: "No entry found",
      content: { email, operation: "no-record" },
    });
  }

  return NextResponse.json({
    banter: "All good",
    content: { email, status: entry.status },
  });
}

export function DELETE(request: NextRequest) {
  const email = request.nextUrl.searchParams.get("email");
  db.deleteFrom("subscriptions")
    .where("email", "=", email)
    .execute()
    .then(() => {
      console.log(`Deleted all records for ${email}`);
    });
  return NextResponse.json({ banter: "All good" }, { status: 200 });
}
