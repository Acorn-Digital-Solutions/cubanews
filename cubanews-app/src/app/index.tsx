import FeedItemCard from "@/components/feed-item-card";
import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import { FeedItem } from "@/models/feed-model";
import { FeedService } from "@/services/feed-service";
import { styles } from "@/styles/cubanews-styles";
import { useState, useEffect, useCallback, useRef } from "react";
import { ActivityIndicator, FlatList, Platform, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { ThemedText } from "@/components/themed-text";

const PAGE_SIZE = 2;

export default function Feed() {
  const [feedItems, setFeedItems] = useState([] as FeedItem[]);
  const [isLoading, setIsLoading] = useState(false);
  const [hasMoreData, setHasMoreData] = useState(true);
  const allIdsRef = useRef(new Set<number>());
  const feedServiceRef = useRef(new FeedService());
  const pageRef = useRef(1);
  const isLoadingRef = useRef(false);
  const hasMoreDataRef = useRef(true);

  const loadNextPage = useCallback(async () => {
    if (isLoadingRef.current || !hasMoreDataRef.current) {
      return;
    }

    isLoadingRef.current = true;
    setIsLoading(true);

    try {
      const result = await feedServiceRef.current.fetchFeedItems({
        page: pageRef.current,
        pageSize: PAGE_SIZE,
        existingIds: allIdsRef.current,
      });

      allIdsRef.current = result.allIds;

      if (result.items.length === 0 || !result.hasNewItems) {
        hasMoreDataRef.current = false;
        setHasMoreData(false);
        return;
      }

      setFeedItems((previousItems) => [...previousItems, ...result.items]);
      pageRef.current += 1;
    } finally {
      isLoadingRef.current = false;
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    loadNextPage();
  }, []);

  const renderFooter = () => {
    if (isLoading && feedItems.length > 0) {
      return <ActivityIndicator style={{ marginVertical: 12 }} />;
    }

    if (!hasMoreData && feedItems.length > 0) {
      return (
        <ThemedText style={{ textAlign: "center", marginVertical: 12 }}>
          No hay mas historias
        </ThemedText>
      );
    }

    return null;
  };

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <FlatList
            data={feedItems}
            keyExtractor={(item) => String(item.id)}
            contentContainerStyle={{ gap: 8 }}
            renderItem={({ item }) => <FeedItemCard item={item} />}
            ListHeaderComponent={<CubanewsHeader text="Titulares" />}
            ListFooterComponent={renderFooter}
            onEndReached={loadNextPage}
            onEndReachedThreshold={0.4}
            showsVerticalScrollIndicator={false}
          />
          {isLoading && feedItems.length === 0 ? (
            <View style={{ marginTop: 16 }}>
              <ActivityIndicator />
            </View>
          ) : null}
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
