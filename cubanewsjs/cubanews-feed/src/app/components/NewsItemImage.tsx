import { useEffect, useState } from "react";
import { Box } from "@mui/joy";

export function NewsItemImage({ image }: { image: string }) {
  const [imageBytes, setImageBytes] = useState(new ArrayBuffer(0));

  useEffect(() => {
    const fetchImage = async () => {
      try {
        const response = await fetch(`/api/image?imageurl=${image}`);
        if (!response.ok) {
          throw new Error("Failed to fetch image");
        }
        const data = await response.arrayBuffer();
        setImageBytes(data);
      } catch (err) {
        console.error(err);
      }
    };

    if (image) {
      fetchImage();
    }
  }, [image]);

  return (
    <Box>
      {imageBytes.byteLength === 0 ? (
        <></>
      ) : (
        <img
          src={`data:image/jpeg;base64,${Buffer.from(imageBytes).toString(
            "base64"
          )}`}
          alt={image}
          style={{ width: "200px", maxWidth: "100%", height: "auto" }}
        />
      )}
    </Box>
  );
}
