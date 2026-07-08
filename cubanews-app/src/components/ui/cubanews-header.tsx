import { styles } from "@/styles/cubanews-styles";
import moment from "moment";
import { Image } from "react-native";
import { ThemedView } from "../themed-view";
import { ThemedText } from "../themed-text";

export function CubanewsHeader() {
  return (
    <ThemedView>
      <ThemedView
        style={{
          flexDirection: "row",
          gap: 8,
        }}
      >
        <Image
          source={require("@/assets/images/identity-transparent-background.png")}
          style={{ width: 60, height: 60, borderRadius: 6 }}
        />
        <ThemedText type="title" style={styles.title}>
          Titulares
        </ThemedText>
      </ThemedView>
      <ThemedText type="subtitle">{moment().format("D MMMM")}</ThemedText>
    </ThemedView>
  );
}
