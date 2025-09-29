import { useEffect, useState } from "react";
import { getBytes, getStorage, ref } from "firebase/storage";
import { Box } from "@mui/joy";
import { initializeApp } from "firebase/app";

export function NewsItemImage({ image }: { image: string }) {
  const [imageBytes, setImageBytes] = useState(new ArrayBuffer());
  useEffect(() => {});

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
