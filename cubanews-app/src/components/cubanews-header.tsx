import { styles } from "@/styles/cubanews-styles";
import moment from "moment";
import { Image } from "react-native";
import { ThemedView } from "./themed-view";
import { ThemedText } from "./themed-text";
import { getLocales } from "expo-localization";

export function CubanewsHeader() {
  const deviceLanguage = getLocales()[0].languageCode ?? "es";
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
      <ThemedText type="subtitle">
        {moment().locale(deviceLanguage).format("dddd, D MMMM")}
      </ThemedText>
    </ThemedView>
  );
}
