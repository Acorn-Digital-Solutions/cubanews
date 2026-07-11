import FeedItemCard from "@/components/feed-item-card";
import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import { FeedItem } from "@/models/feed-model";
import { FeedService } from "@/services/feed-service";
import { styles } from "@/styles/cubanews-styles";
import { useState, useEffect } from "react";
import { Platform, ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

export default function Feed() {
  const [feedItems, setFeedItems] = useState([] as FeedItem[]);
  const [refreshFeed, setRefreshFeed] = useState(true);

  useEffect(() => {
    if (!refreshFeed) {
      return;
    }

    let isMounted = true;

    const loadFeed = async () => {
      try {
        const feedService: FeedService = new FeedService();
        const result = await feedService.fetchFeedItems({
          page: 1,
          pageSize: 10,
        });

        if (isMounted) {
          setFeedItems(result.items);
        }
      } finally {
        if (isMounted) {
          setRefreshFeed(false);
        }
      }
    };

    loadFeed();

    return () => {
      isMounted = false;
    };
  }, [refreshFeed]);

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 8 }}>
            <CubanewsHeader text="Titulares" />
            {feedItems.map((item) => (
              <FeedItemCard key={item.id} item={item} />
            ))}
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
