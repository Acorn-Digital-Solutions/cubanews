import { ThemedView } from "@/components/themed-view";
import { CubanewsHeader } from "@/components/cubanews-header";
import { WebBadge } from "@/components/web-badge";
import ServiceCard, { type Service } from "@/components/service-card";
import { servicesService } from "@/services/services-service";
import { styles } from "@/styles/cubanews-styles";
import { useState, useEffect } from "react";
import { ActivityIndicator, Platform, ScrollView, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { ThemedText } from "@/components/themed-text";

export default function Services() {
  const [services, setServices] = useState<Service[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const loadServices = async () => {
      try {
        const loadedServices = await servicesService.loadServices();
        if (isMounted) {
          setServices(loadedServices);
        }
      } catch (error) {
        console.error("Failed to load services", error);
        if (isMounted) {
          setErrorMessage("No se pudieron cargar los servicios.");
        }
      } finally {
        if (isMounted) {
          setIsLoading(false);
        }
      }
    };

    void loadServices();
    return () => {
      isMounted = false;
    };
  }, []);

  return (
    <ThemedView style={styles.container}>
      <SafeAreaView edges={["top", "left", "right"]} style={styles.safeArea}>
        {Platform.OS === "web" && <WebBadge />}
        <ThemedView style={{ flex: 1, alignSelf: "stretch" }}>
          <CubanewsHeader text="Servicios" showDate={false} />
          <ScrollView style={{ flex: 1 }} contentContainerStyle={{ gap: 8 }}>
            <View style={{ gap: 8 }}>
              {isLoading ? <ActivityIndicator /> : null}
              {errorMessage ? <ThemedText>{errorMessage}</ThemedText> : null}
              {services.map((service) => (
                <ServiceCard key={service.id} service={service} />
              ))}
            </View>
          </ScrollView>
        </ThemedView>
      </SafeAreaView>
    </ThemedView>
  );
}
