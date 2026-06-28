import InfinityColumn from "@/components/infinity-column";
import { ThemedText } from "@/components/themed-text";
import { ThemedView } from "@/components/themed-view";
import { WebBadge } from "@/components/web-badge";
import { styles } from "@/styles/cubanews-styles";
import { Platform } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";

export default function Feed() {
  return (
    <ThemedView style={styles.container}>
      <SafeAreaView style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView>
          <ThemedText type="code" style={styles.title}>
            Cubanews Feed
          </ThemedText>
          <InfinityColumn />
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
