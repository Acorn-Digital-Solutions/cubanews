import { useEffect, useState } from "react";
import { getBytes, getStorage, ref } from "firebase/storage";
import { Box } from "@mui/joy";
import { initializeApp } from "firebase/app";

export function NewsItemImage({ image }: { image: string }) {
  const [imageBytes, setImageBytes] = useState(new ArrayBuffer());
  useEffect(() => {
    if (imageBytes.byteLength === 0) {
      loadImage().then((imageBytes) => {
        setImageBytes(imageBytes);
      });
    }
  });

  const firebaseConfig = {
    apiKey: "AIzaSyBEdpj3q8rxQ4iTqJf1ps4YMpgGwO8C6vU",
    authDomain: "cubanews-fbaad.firebaseapp.com",
    projectId: "cubanews-fbaad",
    storageBucket: "cubanews-fbaad.firebasestorage.app",
    messagingSenderId: "364287175875",
    appId: "1:364287175875:web:cda629727a545968864676",
    measurementId: "G-W5WM6VMN6N",
  };

  async function loadImage(): Promise<ArrayBuffer> {
    const firebaseApp = initializeApp(firebaseConfig);
    const storage = getStorage(firebaseApp);
    // Create a reference from a Google Cloud Storage URI
    const gsReference = ref(storage, image);
    return getBytes(gsReference);
  }

  return (
    <Box>
      {imageBytes.byteLength > 0 ? (
        <img
          src={`data:image/jpeg;base64,${Buffer.from(imageBytes).toString(
            "base64"
          )}`}
          alt="news"
          style={{ maxWidth: "100%", height: "auto" }}
        />
      ) : (
        <span>Loading image...</span>
      )}
    </Box>
  );
}
