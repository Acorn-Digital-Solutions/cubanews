import {
  ImageLoadingState,
  type FeedItem,
  type NewsSourceName,
} from "@/models/feed-model";
import { useTheme } from "@/hooks/use-theme";
import {
  Linking,
  Pressable,
  Share,
  StyleSheet,
  View,
  ActivityIndicator,
  Image,
} from "react-native";
import { useMemo, useState } from "react";
import { ThemedText } from "./themed-text";

type FeedItemCardProps = {
  item: FeedItem;
};

const SOURCE_LABELS: Record<NewsSourceName, string> = {
  adncuba: "ADN Cuba",
  catorceymedio: "14ymedio",
  diariodecuba: "Diario de Cuba",
  cibercuba: "CiberCuba",
  eltoque: "elTOQUE",
  cubanet: "CubaNet",
};

function getRelativeTimeLabel(isoDate: string): string {
  const parsed = new Date(isoDate);

  if (Number.isNaN(parsed.getTime())) {
    return "ahora";
  }

  const diffMs = parsed.getTime() - Date.now();
  const minuteMs = 60 * 1000;
  const hourMs = 60 * minuteMs;
  const dayMs = 24 * hourMs;

  if (Math.abs(diffMs) < minuteMs) {
    return "ahora";
  }

  if (Math.abs(diffMs) < hourMs) {
    const minutes = Math.round(Math.abs(diffMs) / minuteMs);
    const unit = minutes === 1 ? "minuto" : "minutos";
    return diffMs < 0 ? `hace ${minutes} ${unit}` : `en ${minutes} ${unit}`;
  }

  if (Math.abs(diffMs) < dayMs) {
    const hours = Math.round(Math.abs(diffMs) / hourMs);
    const unit = hours === 1 ? "hora" : "horas";
    return diffMs < 0 ? `hace ${hours} ${unit}` : `en ${hours} ${unit}`;
  }

  const days = Math.round(Math.abs(diffMs) / dayMs);
  const unit = days === 1 ? "dia" : "dias";
  return diffMs < 0 ? `hace ${days} ${unit}` : `en ${days} ${unit}`;
}

export default function FeedItemCard({ item }: FeedItemCardProps) {
  const theme = useTheme();
  const [isSaved, setIsSaved] = useState(false);

  const relativeTime = useMemo(
    () => getRelativeTimeLabel(item.isoDate),
    [item.isoDate],
  );
  const sourceLabel = SOURCE_LABELS[item.source] ?? item.source;
  const sourceBadgeText = sourceLabel.slice(0, 2).toUpperCase();
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
            <ThemedText type="smallBold">{sourceBadgeText}</ThemedText>
          </View>
          <ThemedText type="smallBold" themeColor="textSecondary">
            {sourceLabel}
          </ThemedText>
        </View>
        <ThemedText type="small" themeColor="textSecondary">
          {relativeTime}
        </ThemedText>
      </View>

      {hasImage && item.imageLoadingState === ImageLoadingState.LOADING ? (
        <View style={styles.imagePlaceholder}>
          <ActivityIndicator />
        </View>
      ) : null}

      {hasImage && item.imageLoadingState !== ImageLoadingState.LOADING ? (
        <Pressable onPress={openArticle} style={styles.imageContainer}>
          <Image
            source={{ uri: item.image ?? undefined }}
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
        <Pressable onPress={() => setIsSaved((prev) => !prev)}>
          <ThemedText
            type="small"
            themeColor={isSaved ? "text" : "textSecondary"}
          >
            {isSaved ? "Guardar ✓" : "Guardar"}
          </ThemedText>
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
