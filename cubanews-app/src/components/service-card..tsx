import { useTheme } from "@/hooks/use-theme";
import { MaterialDesignIcons } from "@react-native-vector-icons/material-design-icons";
import { Alert, Linking, Pressable, StyleSheet, View } from "react-native";
import { ThemedText } from "./themed-text";

export type ServiceStatus = "inReview" | "approved" | "rejected" | "expired";

export type ServiceContactInfo = {
  emailAddress?: string;
  phoneNumber?: string;
  websiteURL?: string;
  facebook?: string;
  instagram?: string;
};

export type Service = {
  id: string;
  businessName: string;
  description: string;
  contactInfo: ServiceContactInfo;
  status: ServiceStatus;
};

type ServiceCardProps = {
  service: Service;
  showMyServices?: boolean;
  onPress?: (service: Service) => void;
  onEdit?: (service: Service) => void;
  onDelete?: (service: Service) => void;
};

const statusDetails: Record<ServiceStatus, { label: string; color: string }> = {
  inReview: { label: "En revision", color: "#ED6C02" },
  approved: { label: "Aprobado", color: "#2E7D32" },
  rejected: { label: "Rechazado", color: "#D32F2F" },
  expired: { label: "Rechazado", color: "#D32F2F" },
};

function truncateToWords(text: string, maxWords: number): string {
  const words = text.trim().split(/\s+/);
  return words.length <= maxWords
    ? text
    : `${words.slice(0, maxWords).join(" ")}...`;
}

function normalizeUrl(value: string): string {
  return /^[a-z][a-z\d+.-]*:/i.test(value) ? value : `https://${value}`;
}

export default function ServiceCard({
  service,
  showMyServices = false,
  onPress,
  onEdit,
  onDelete,
}: ServiceCardProps) {
  const theme = useTheme();
  const { contactInfo } = service;
  const status = statusDetails[service.status];

  const openUrl = async (url: string) => {
    const destination = normalizeUrl(url);
    if (await Linking.canOpenURL(destination)) {
      await Linking.openURL(destination);
    }
  };

  const callNumber = async () => {
    const number = contactInfo.phoneNumber?.replace(/[^\d+]/g, "") ?? "";
    if (number) {
      await openUrl(`tel:${number}`);
    }
  };

  const emailService = async () => {
    if (contactInfo.emailAddress) {
      await openUrl(`mailto:${contactInfo.emailAddress}`);
    }
  };

  const confirmDelete = () => {
    Alert.alert(
      "Eliminar Servicio",
      `Esta seguro que desea eliminar '${service.businessName}'? Esta accion no se puede deshacer.`,
      [
        { text: "Cancelar", style: "cancel" },
        {
          text: "Eliminar",
          style: "destructive",
          onPress: () => onDelete?.(service),
        },
      ],
    );
  };

  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={`Ver servicio ${service.businessName}`}
      onPress={() => onPress?.(service)}
      style={({ pressed }) => [
        styles.card,
        {
          backgroundColor: theme.backgroundElement,
          opacity: pressed ? 0.82 : 1,
        },
      ]}
    >
      <View style={styles.header}>
        <ThemedText style={styles.businessName} numberOfLines={2}>
          {service.businessName}
        </ThemedText>
        {showMyServices ? (
          <View
            style={[
              styles.statusBadge,
              { backgroundColor: `${status.color}1F` },
            ]}
          >
            <ThemedText style={[styles.statusText, { color: status.color }]}>
              {status.label}
            </ThemedText>
          </View>
        ) : null}
      </View>

      <ThemedText
        style={[styles.description, { color: theme.textSecondary }]}
        numberOfLines={4}
      >
        {truncateToWords(service.description, 50)}
      </ThemedText>

      <View style={styles.footer}>
        <View style={styles.contactActions}>
          {contactInfo.emailAddress ? (
            <ContactButton
              label="Enviar correo"
              icon="email"
              onPress={emailService}
            />
          ) : null}
          {contactInfo.phoneNumber ? (
            <ContactButton label="Llamar" icon="phone" onPress={callNumber} />
          ) : null}
          {contactInfo.facebook ? (
            <ContactButton
              label="Abrir Facebook"
              icon="facebook"
              onPress={() => openUrl(contactInfo.facebook!)}
            />
          ) : null}
          {contactInfo.instagram ? (
            <ContactButton
              label="Abrir Instagram"
              icon="instagram"
              onPress={() => openUrl(contactInfo.instagram!)}
            />
          ) : null}
          {contactInfo.websiteURL ? (
            <ContactButton
              label="Abrir sitio web"
              icon="web"
              onPress={() => openUrl(contactInfo.websiteURL!)}
            />
          ) : null}
        </View>

        {showMyServices ? (
          <View style={styles.managementActions}>
            <ContactButton
              label="Editar servicio"
              icon="pencil"
              color="#0A84FF"
              onPress={() => onEdit?.(service)}
            />
            <ContactButton
              label="Eliminar servicio"
              icon="delete-outline"
              color="#D32F2F"
              onPress={confirmDelete}
            />
          </View>
        ) : null}
      </View>
    </Pressable>
  );
}

type ContactButtonProps = {
  label: string;
  icon: React.ComponentProps<typeof MaterialDesignIcons>["name"];
  color?: string;
  onPress: () => void;
};

function ContactButton({
  label,
  icon,
  color = "#000000",
  onPress,
}: ContactButtonProps) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      hitSlop={8}
      onPress={(event) => {
        event.stopPropagation();
        onPress();
      }}
      style={styles.iconButton}
    >
      <MaterialDesignIcons name={icon} size={27} color={color} />
    </Pressable>
  );
}

const styles = StyleSheet.create({
  card: {
    minHeight: 150,
    padding: 16,
    borderRadius: 12,
    gap: 12,
    shadowColor: "#000000",
    shadowOpacity: 0.16,
    shadowRadius: 2,
    shadowOffset: { width: 0, height: 1 },
    elevation: 2,
  },
  header: {
    flexDirection: "row",
    alignItems: "flex-start",
    gap: 12,
  },
  businessName: {
    flex: 1,
    fontSize: 20,
    fontWeight: "700",
    lineHeight: 24,
  },
  statusBadge: {
    borderRadius: 18,
    paddingHorizontal: 10,
    paddingVertical: 6,
  },
  statusText: {
    fontSize: 13,
    fontWeight: "600",
  },
  description: {
    flex: 1,
    fontSize: 17,
    lineHeight: 23,
  },
  footer: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: "auto",
  },
  contactActions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    flexShrink: 1,
  },
  managementActions: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  iconButton: {
    minWidth: 28,
    minHeight: 28,
    alignItems: "center",
    justifyContent: "center",
  },
});
