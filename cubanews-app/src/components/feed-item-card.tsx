import {
  ImageLoadingState,
  type FeedItem,
  type NewsSourceName,
} from "@/models/feed-model";
import { useTheme } from "@/hooks/use-theme";
import { app } from "@/constants/firebaseConfig";
import { getDownloadURL, getStorage, ref } from "firebase/storage";

import {
  Linking,
  Pressable,
  Share,
  StyleSheet,
  View,
  ActivityIndicator,
  Image,
  type ImageSourcePropType,
} from "react-native";
import { useEffect, useMemo, useState } from "react";
import { ThemedText } from "./themed-text";
import { getLocales } from "expo-localization";
import moment from "moment";

require("moment/locale/es");

type FeedItemCardProps = {
  item: FeedItem;
};

function getSourceInfo(source: NewsSourceName): {
  sourceLabel: string;
  sourceImage?: ImageSourcePropType;
} {
  switch (source) {
    case "adncuba":
      return {
        sourceLabel: "ADN Cuba",
        sourceImage: require("../../assets/images/sources/adncuba.jpg"),
      };
    case "aserenoticias":
      return {
        sourceLabel: "Asere Noticias",
        sourceImage: require("../../assets/images/sources/aserenoticias.jpeg"),
      };
    case "catorceymedio":
      return {
        sourceLabel: "14yMedio",
        sourceImage: require("../../assets/images/sources/catorceymedio.jpg"),
      };
    case "cibercuba":
      return {
        sourceLabel: "CiberCuba",
        sourceImage: require("../../assets/images/sources/cibercuba.png"),
      };
    case "cubanet":
      return {
        sourceLabel: "CubaNet",
        sourceImage: require("../../assets/images/sources/cubanet.png"),
      };
    case "cubanosporelmundo":
      return {
        sourceLabel: "Cubanos por el Mundo",
        sourceImage: require("../../assets/images/sources/cubanosporelmundo.jpg"),
      };
    case "diariodecuba":
      return {
        sourceLabel: "Diario de Cuba",
        sourceImage: require("../../assets/images/sources/ddc.jpg"),
      };
    case "eltoque":
      return {
        sourceLabel: "elTOQUE",
        sourceImage: require("../../assets/images/sources/eltoque.png"),
      };
    case "cubanoticias360":
      return {
        sourceLabel: "Cuba Noticias 360",
        sourceImage: require("../../assets/images/sources/cubanoticias360.jpeg"),
      };
    case "directoriocubano":
      return {
        sourceLabel: "Directorio Cubano",
        sourceImage: require("../../assets/images/sources/directoriocubano.png"),
      };
    case "havanatimes":
      return {
        sourceLabel: "Havana Times",
        sourceImage: require("../../assets/images/sources/havanatimes.jpeg"),
      };
    case "martinoticias":
      return {
        sourceLabel: "Marti Noticias",
        sourceImage: require("../../assets/images/sources/martinoticias.png"),
      };
    case "periodicocubano":
      return {
        sourceLabel: "Periodico Cubano",
        sourceImage: require("../../assets/images/sources/periodicocubano.png"),
      };
    default:
      return { sourceLabel: source };
  }
}

function getRelativeTimeLabel(isoDate: string, locale: string): string {
  const parsed = moment(isoDate);
  if (!parsed.isValid()) {
    return "ahora";
  }
  return parsed.locale(locale).fromNow();
}

// Resolves the image as a URL that can be rendered by React Native Image.
async function loadImage(item: FeedItem): Promise<string> {
  if (!item.image) {
    return "";
  }

  try {
    const imagePathOrUrl = item.image.trim();
    return await getDownloadURL(ref(getStorage(app), imagePathOrUrl));
  } catch (error) {
    console.error(error);
    return "";
  }
}

export default function FeedItemCard({ item }: FeedItemCardProps) {
  const theme = useTheme();
  const [isSaved, setIsSaved] = useState(false);
  const deviceLanguage = getLocales()[0].languageCode ?? "es";
  const { sourceLabel, sourceImage } = getSourceInfo(item.source);
  const [imageLoadingState, setImageLoadingState] = useState(
    item.imageLoadingState,
  );
  const [mainImage, setMainImage] = useState("");

  const relativeTime = useMemo(
    () => getRelativeTimeLabel(item.isoDate, deviceLanguage),
    [item.isoDate, deviceLanguage],
  );
  const hasImage = Boolean(item.image && item.image.length > 0);

  const openArticle = async () => {
    if (!item.url) {
      return;
    }

    await Linking.openURL(item.url);
  };

  const shareArticle = async () => {
    if (!item.url) {
      await Share.share({ message: item.title });
      return;
    }

    await Share.share({
      message: item.url,
      url: item.url,
      title: item.title,
    });
  };

  const likeArticle = async () => {
    console.log("Like Article");
  };

  useEffect(() => {
    loadImage(item)
      .then((imageUrl) => {
        if (imageUrl) {
          setImageLoadingState(ImageLoadingState.LOADED);
          setMainImage(imageUrl);
        } else {
          setImageLoadingState(ImageLoadingState.FAILED);
        }
      })
      .catch((error) => {
        console.log(error);
        setImageLoadingState(ImageLoadingState.FAILED);
      });
  });

  return (
    <View style={[styles.card, { backgroundColor: theme.backgroundElement }]}>
      <View style={styles.headerRow}>
        <View style={styles.sourceRow}>
          <View
            style={[
              styles.sourceBadge,
              { backgroundColor: theme.backgroundSelected },
            ]}
          >
            {sourceImage ? (
              <Image source={sourceImage} style={{ width: 20, height: 20 }} />
            ) : null}
          </View>
          <ThemedText type="smallBold" themeColor="textSecondary">
            {sourceLabel}
          </ThemedText>
        </View>
        <ThemedText type="small" themeColor="textSecondary">
          {relativeTime}
        </ThemedText>
      </View>

      {hasImage && imageLoadingState === ImageLoadingState.LOADING ? (
        <View style={styles.imagePlaceholder}>
          <ActivityIndicator />
        </View>
      ) : null}

      {hasImage && imageLoadingState !== ImageLoadingState.LOADING ? (
        <Pressable onPress={openArticle} style={styles.imageContainer}>
          <Image
            source={{
              uri: mainImage,
            }}
            resizeMode="cover"
            style={styles.image}
          />
        </Pressable>
      ) : null}

      <Pressable onPress={openArticle}>
        <ThemedText style={styles.title}>{item.title}</ThemedText>
      </Pressable>

      <View
        style={[
          styles.separator,
          { backgroundColor: theme.backgroundSelected },
        ]}
      />

      <View style={styles.actionRow}>
        <View style={styles.actionSpacer} />
        {/* <Pressable onPress={() => setIsSaved((prev) => !prev)}>
          <ThemedText
            type="small"
            themeColor={isSaved ? "text" : "textSecondary"}
          >
            {isSaved ? "Guardar ✓" : "Guardar"}
          </ThemedText>
        </Pressable> */}
        <Pressable>
          <ThemedText onPress={likeArticle}>Interesante</ThemedText>
        </Pressable>
        <Pressable onPress={shareArticle}>
          <ThemedText type="small" themeColor="textSecondary">
            Compartir
          </ThemedText>
        </Pressable>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    padding: 12,
    gap: 8,
    shadowColor: "#000",
    shadowOpacity: 0.2,
    shadowRadius: 1,
    shadowOffset: { width: 0, height: 1 },
    elevation: 2,
  },
  headerRow: {
    alignItems: "center",
    flexDirection: "row",
    justifyContent: "space-between",
  },
  sourceRow: {
    alignItems: "center",
    flexDirection: "row",
    gap: 8,
  },
  sourceBadge: {
    alignItems: "center",
    borderRadius: 4,
    height: 16,
    justifyContent: "center",
    width: 20,
  },
  imagePlaceholder: {
    alignItems: "center",
    borderRadius: 8,
    height: 120,
    justifyContent: "center",
  },
  imageContainer: {
    borderRadius: 8,
    overflow: "hidden",
  },
  image: {
    height: 120,
    width: "100%",
  },
  title: {
    fontSize: 16,
    fontWeight: "600",
    lineHeight: 22,
  },
  separator: {
    height: 1,
    marginVertical: 4,
  },
  actionRow: {
    alignItems: "center",
    flexDirection: "row",
    gap: 20,
  },
  actionSpacer: {
    flex: 1,
  },
});
