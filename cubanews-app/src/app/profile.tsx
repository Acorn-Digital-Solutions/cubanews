import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import { styles } from "@/styles/cubanews-styles";
import { useEffect } from "react";
import { Platform, ScrollView, StyleSheet, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import ProfilePageSection from "@/components/profile-page-section";
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
            <ProfilePageSection title="Preferencias" separator={true}>
              <ThemedText type="default">
                Selecciona tus fuentes de noticias preferidas para personalizar
                tus titulares
              </ThemedText>
            </ProfilePageSection>
            <ProfilePageSection title="Acerca de Cubanews" separator={false}>
              <ThemedText type="default">La mission de Cubanews</ThemedText>
            </ProfilePageSection>
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
