import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import { styles } from "@/styles/cubanews-styles";
import { useState } from "react";
import {
  Image,
  ImageSourcePropType,
  Linking,
  Platform,
  ScrollView,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import ProfilePageSection from "@/components/profile-page-section";
import { NewsSourceName } from "@/models/feed-model";
import { preferencesService } from "@/services/preferences-service";

interface SourcePreference {
  id: NewsSourceName;
  displayName: string;
  image: ImageSourcePropType;
}

const PREFERRED_SOURCES: SourcePreference[] = [
  {
    id: NewsSourceName.ADNCUBA,
    displayName: "ADN Cuba",
    image: require("@/assets/images/sources/adncuba.jpg"),
  },
  {
    id: NewsSourceName.CATORCEYMEDIO,
    displayName: "14yMedio",
    image: require("@/assets/images/sources/catorceymedio.jpg"),
  },
  {
    id: NewsSourceName.DIARIODECUBA,
    displayName: "Diario De Cuba",
    image: require("@/assets/images/sources/ddc.jpg"),
  },
  {
    id: NewsSourceName.CIBERCUBA,
    displayName: "Cibercuba",
    image: require("@/assets/images/sources/cibercuba.png"),
  },
  {
    id: NewsSourceName.ELTOQUE,
    displayName: "el TOQUE",
    image: require("@/assets/images/sources/eltoque.png"),
  },
  {
    id: NewsSourceName.CUBANET,
    displayName: "Cubanet",
    image: require("@/assets/images/sources/cubanet.png"),
  },
  {
    id: NewsSourceName.ASERENOTICIAS,
    displayName: "Asere Noticias",
    image: require("@/assets/images/sources/aserenoticias.jpeg"),
  },
  {
    id: NewsSourceName.CUBANOSPORELMUNDO,
    displayName: "Cubanos por el Mundo",
    image: require("@/assets/images/sources/cubanosporelmundo.jpg"),
  },
  {
    id: NewsSourceName.directoriocubano,
    displayName: "Directorio Cubano",
    image: require("@/assets/images/sources/directoriocubano.png"),
  },
  {
    id: NewsSourceName.HAVANATIMES,
    displayName: "Havana Times",
    image: require("@/assets/images/sources/havanatimes.jpeg"),
  },
  {
    id: NewsSourceName.MARTINOTICIAS,
    displayName: "Martí Noticias",
    image: require("@/assets/images/sources/martinoticias.png"),
  },
  {
    id: NewsSourceName.PERIODICOCUBANO,
    displayName: "Periódico Cubano",
    image: require("@/assets/images/sources/periodicocubano.png"),
  },
  {
    id: NewsSourceName.CUBANOTICIAS360,
    displayName: "CubaNoticias360",
    image: require("@/assets/images/sources/cubanoticias360.jpeg"),
  },
];

export default function Profile() {
  const [selectedSources, setSelectedSources] = useState<NewsSourceName[]>([]);

  const toggleSource = async (sourceId: NewsSourceName) => {
    const newSelected = selectedSources.includes(sourceId)
      ? selectedSources.filter((id) => id !== sourceId)
      : [...selectedSources, sourceId];

    setSelectedSources(newSelected);

    try {
      await preferencesService.pushPreferredSources(newSelected);
    } catch (error) {
      console.error("Error syncing preferred sources", error);
    }
  };

  const rows: SourcePreference[][] = [];
  for (let i = 0; i < PREFERRED_SOURCES.length; i += 2) {
    rows.push(PREFERRED_SOURCES.slice(i, i + 2));
  }

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView edges={["top", "left", "right"]} style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <CubanewsHeader text="Perfil" showDate={false} />
          <ScrollView
            style={{ flex: 1 }}
            contentContainerStyle={{ gap: 16, paddingBottom: 24 }}
          >
            <View style={pageStyles.accountBanner}>
              <Text style={pageStyles.accountBannerText}>
                Para anunciar negocios y demás funcionalidades premium, crea tu
                cuenta.
              </Text>
              <TouchableOpacity
                activeOpacity={0.8}
                style={pageStyles.appleSignInButton}
              >
                <Text style={pageStyles.appleLogo}></Text>
                <Text style={pageStyles.appleSignInText}>
                  Sign in with Apple
                </Text>
              </TouchableOpacity>
            </View>

            <ProfilePageSection title="Preferencias" separator={true}>
              <Text style={pageStyles.sectionSubtitle}>
                Selecciona tus fuentes de noticias preferidas para personalizar
                tu feed
              </Text>
              <View style={pageStyles.gridContainer}>
                {rows.map((row, rowIndex) => (
                  <View key={rowIndex} style={pageStyles.gridRow}>
                    {row.map((source) => {
                      const isSelected = selectedSources.includes(source.id);
                      return (
                        <TouchableOpacity
                          key={source.id}
                          activeOpacity={0.7}
                          onPress={() => toggleSource(source.id)}
                          style={[
                            pageStyles.pillButton,
                            isSelected
                              ? pageStyles.pillSelected
                              : pageStyles.pillUnselected,
                          ]}
                        >
                          <Image
                            source={source.image}
                            style={pageStyles.pillIcon}
                          />
                          <Text
                            style={[
                              pageStyles.pillText,
                              isSelected
                                ? pageStyles.pillTextSelected
                                : pageStyles.pillTextUnselected,
                            ]}
                            numberOfLines={2}
                          >
                            {source.displayName}
                          </Text>
                        </TouchableOpacity>
                      );
                    })}
                    {row.length === 1 && <View style={{ flex: 1 }} />}
                  </View>
                ))}
              </View>
            </ProfilePageSection>

            <ProfilePageSection title="Acerca de CubaNews" separator={false}>
              <Text style={pageStyles.aboutText}>
                La misión de CubaNews es amplificar el mensaje de la prensa
                independiente cubana . Ver más en nuestra web{" "}
                <Text
                  style={pageStyles.aboutLink}
                  onPress={() =>
                    Linking.openURL("https://www.cubanews.icu/about")
                  }
                >
                  cubanews.icu
                </Text>
              </Text>
            </ProfilePageSection>
            <View style={pageStyles.scrollEndSpacer} />
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}

const pageStyles = StyleSheet.create({
  accountBanner: {
    gap: 12,
    marginBottom: 8,
  },
  accountBannerText: {
    fontSize: 14,
    color: "#6B7280",
    lineHeight: 20,
  },
  appleSignInButton: {
    backgroundColor: "#000000",
    borderRadius: 8,
    height: 48,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 8,
  },
  appleLogo: {
    color: "#FFFFFF",
    fontSize: 20,
    fontWeight: "bold",
  },
  appleSignInText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
  sectionSubtitle: {
    fontSize: 14,
    color: "#6B7280",
    lineHeight: 20,
    marginBottom: 8,
  },
  gridContainer: {
    gap: 10,
    marginTop: 4,
  },
  gridRow: {
    flexDirection: "row",
    gap: 10,
  },
  pillButton: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 12,
    paddingVertical: 8,
    borderRadius: 25,
    borderWidth: 1.5,
    borderColor: "#007AFF",
    minHeight: 44,
  },
  pillUnselected: {
    backgroundColor: "#FFFFFF",
  },
  pillSelected: {
    backgroundColor: "#007AFF",
  },
  pillIcon: {
    width: 22,
    height: 22,
    borderRadius: 4,
    marginRight: 8,
  },
  pillText: {
    fontSize: 14,
    fontWeight: "600",
    flexShrink: 1,
  },
  pillTextUnselected: {
    color: "#007AFF",
  },
  pillTextSelected: {
    color: "#FFFFFF",
  },
  aboutText: {
    fontSize: 14,
    color: "#6B7280",
    lineHeight: 20,
  },
  aboutLink: {
    color: "#007AFF",
    textDecorationLine: "underline",
  },
  scrollEndSpacer: {
    height: 120,
  },
});
