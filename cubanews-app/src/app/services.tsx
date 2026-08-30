import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import { styles } from "@/styles/cubanews-styles";
import { useState, useEffect } from "react";
import { Platform, ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { ThemedText } from "@/components/themed-text";

export default function Services() {
  useEffect(() => {});

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView edges={["top", "left", "right"]} style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <CubanewsHeader text="Servicios" showDate={false} />
          <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 8 }}>
            <View style={{ gap: 8 }}>
              <ThemedText>Servicios</ThemedText>
            </View>
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
