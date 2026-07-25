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
  const [headlineItems, setHeadlineItems] = useState([] as FeedItem[]);
  const [moreStories, setMoreStories] = useState([] as FeedItem[]);
  const [isInitializing, setIsInitializing] = useState(true);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [hasMoreData, setHasMoreData] = useState(true);
  const allIdsRef = useRef(new Set<number>());
  const feedServiceRef = useRef(new FeedService());
  const nextMoreStoriesPageRef = useRef(2);
  const isLoadingMoreRef = useRef(false);
  const hasMoreDataRef = useRef(true);

  const loadMoreStories = useCallback(async () => {
    if (isLoadingMoreRef.current || !hasMoreDataRef.current) {
      return;
    }

    isLoadingMoreRef.current = true;
    setIsLoadingMore(true);

    try {
      const result = await feedServiceRef.current.fetchFeedItems({
        page: nextMoreStoriesPageRef.current,
        pageSize: PAGE_SIZE,
        existingIds: allIdsRef.current,
      });

      allIdsRef.current = result.allIds;

      if (result.items.length === 0 || !result.hasNewItems) {
        hasMoreDataRef.current = false;
        setHasMoreData(false);
        return;
      }

      setMoreStories((previousItems) => [...previousItems, ...result.items]);
      nextMoreStoriesPageRef.current += 1;
    } finally {
      isLoadingMoreRef.current = false;
      setIsLoadingMore(false);
    }
  }, []);

  useEffect(() => {
    let isMounted = true;

    const initializeFeed = async () => {
      try {
        const headlineResult = await feedServiceRef.current.fetchFeedItems({
          page: 1,
          pageSize: PAGE_SIZE,
          existingIds: allIdsRef.current,
        });

        if (!isMounted) {
          return;
        }

        allIdsRef.current = headlineResult.allIds;
        setHeadlineItems(headlineResult.items);

        await loadMoreStories();
      } finally {
        if (isMounted) {
          setIsInitializing(false);
        }
      }
    };

    initializeFeed();

    return () => {
      isMounted = false;
    };
  }, []);

  const renderFooter = () => {
    if (isLoadingMore && moreStories.length > 0) {
      return <ActivityIndicator style={{ marginVertical: 12 }} />;
    }

    if (!hasMoreData && moreStories.length > 0) {
      return (
        <ThemedText style={{ textAlign: "center", marginVertical: 12 }}>
          No hay mas historias
        </ThemedText>
      );
    }

    return null;
  };

  const renderHeader = () => {
    return (
      <View style={{ gap: 8 }}>
        <CubanewsHeader text="Titulares" />
        {headlineItems.map((item) => (
          <FeedItemCard key={item.id} item={item} />
        ))}
        <ThemedText type="subtitle">Mas Historias</ThemedText>
      </View>
    );
  };

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView edges={["top", "left", "right"]} style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <FlatList
            data={moreStories}
            keyExtractor={(item) => String(item.id)}
            contentContainerStyle={{ gap: 8 }}
            renderItem={({ item }) => <FeedItemCard item={item} />}
            ListHeaderComponent={renderHeader}
            ListFooterComponent={renderFooter}
            onEndReached={loadMoreStories}
            onEndReachedThreshold={0.4}
            showsVerticalScrollIndicator={false}
          />
          {isInitializing ? (
            <View style={{ marginTop: 16 }}>
              <ActivityIndicator />
            </View>
          ) : null}
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
