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
import { ThemedText } from "@/components/themed-text";

export default function Profile() {
  useEffect(() => {});

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView edges={["top", "left", "right"]} style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <CubanewsHeader text="Perfil" showDate={false} />
          <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 8 }}>
            <View style={{ gap: 8 }}>
              <ThemedText>Perfil</ThemedText>
            </View>
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
