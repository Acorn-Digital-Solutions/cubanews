import { NextRequest, NextResponse } from "next/server";
import { initializeApp } from "@firebase/app";
import { getBytes, getStorage, ref } from "@firebase/storage";
import { ImageResponseData } from "@/app/interfaces";

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
  request: NextRequest
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
