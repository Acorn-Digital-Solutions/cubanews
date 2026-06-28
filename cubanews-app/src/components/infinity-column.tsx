import { FeedItem } from "@/models/feed-model";
import { ScrollView, View } from "react-native";
import { useEffect, useState } from "react";
import { FeedService } from "@/services/feed-service";
import FeedItemCard from "./feed-item-card";

export default function InfinityColumn() {
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
    <ScrollView>
      <View style={{ gap: 8 }}>
        {feedItems.map((item) => (
          <FeedItemCard key={item.id} item={item} />
        ))}
      </View>
    </ScrollView>
  );
}
