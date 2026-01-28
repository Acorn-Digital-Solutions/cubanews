import { NextRequest, NextResponse } from "next/server";
import { initializeApp } from "@firebase/app";
import { getBytes, getStorage, ref } from "@firebase/storage";
import { ImageResponseData } from "@/app/interfaces";
import { listAll, deleteObject, getMetadata } from "@firebase/storage";

const firebaseConfig = {
  apiKey: "AIzaSyBEdpj3q8rxQ4iTqJf1ps4YMpgGwO8C6vU",
  authDomain: "cubanews-fbaad.firebaseapp.com",
  projectId: "cubanews-fbaad",
  storageBucket: "cubanews-fbaad.firebasestorage.app",
  messagingSenderId: "364287175875",
  appId: "1:364287175875:web:cda629727a545968864676",
  measurementId: "G-W5WM6VMN6N",
};
const firebaseApp = initializeApp(firebaseConfig);
const storage = getStorage(firebaseApp);

export async function GET(
  request: NextRequest,
): Promise<NextResponse<ImageResponseData>> {
  const imageurl = request.nextUrl.searchParams.get("imageurl");
  if (imageurl === null) {
    console.log("Image url is null");
    return NextResponse.json({ content: undefined }, { status: 400 });
  }
  const gsReference = ref(storage, imageurl);
  const bytes = await getBytes(gsReference).catch(() => {
    throw Error();
  });
  console.log(`Bytes ${bytes.byteLength}`);
  const blob = new Blob([bytes]);
  return new NextResponse(blob, {
    status: 200,
    headers: {
      "Content-Type": "application/octet-stream",
      "Content-Disposition": "inline",
    },
  });
}

export async function DELETE(
  request: NextRequest,
): Promise<
  NextResponse<{ banter: string | undefined; dryrun?: string | null }>
> {
  console.log("Received request to delete old images");
  if (request.headers.get("ADMIN_TOKEN") !== process.env.ADMIN_TOKEN) {
    return NextResponse.json(
      {
        banter: "You are not authorized to refresh the feed",
      },
      { status: 401, statusText: "Unauthorized" },
    );
  }

  const env = request.nextUrl.searchParams.get("env") ?? "PROD";
  const imageDirectory = env === "PROD" ? "images/" : "devimages/";
  const daysOld = parseInt(
    request.nextUrl.searchParams.get("daysold") ?? "7",
    10,
  );

  try {
    const storageRef = ref(storage, imageDirectory);
    const listResult = await listAll(storageRef);
    console.log(
      `Found ${listResult.prefixes.length} subdirectories in ${imageDirectory}`,
    );

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - daysOld);
    var deletedCount = 0;

    // Process all subdirectories (e.g., devimages/catorceymedio, devimages/cibercuba, etc.)
    for (const folderRef of listResult.prefixes) {
      const folderListResult = await listAll(folderRef);
      console.log(
        `Found ${folderListResult.items.length} items in ${folderRef.fullPath}`,
      );

      const deletePromises = folderListResult.items.map(async (itemRef) => {
        const metadata = await getMetadata(itemRef);
        console.log(`Metadata for ${itemRef.fullPath}:`, metadata);
        const createdAt = new Date(metadata.timeCreated);

        if (createdAt < cutoffDate) {
          if (!request.nextUrl.searchParams.get("dryrun")) {
            await deleteObject(itemRef);
          }
          deletedCount++;
          console.log(`Deleted ${itemRef.fullPath}`);
        } else {
          console.log(`Retained ${itemRef.fullPath} (created at ${createdAt})`);
        }
      });

      await Promise.all(deletePromises);
    }

    console.log(`Deletion complete. Total deleted: ${deletedCount}`);
    return NextResponse.json(
      {
        banter: `Old images deleted successfully. Total deleted: ${deletedCount}`,
        dryrun: request.nextUrl.searchParams.get("dryrun"),
      },
      { status: 200 },
    );
  } catch (error) {
    console.error("Error deleting old images:", error);
    return NextResponse.json(
      { banter: "Error deleting images" },
      { status: 500 },
    );
  }
}
