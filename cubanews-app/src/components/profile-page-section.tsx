import { type ReactNode } from "react";
import { View, StyleSheet } from "react-native";
import { ThemedText } from "./themed-text";

export default function ProfilePageSection({
  title,
  separator = true,
  children,
}: {
  title?: string;
  separator?: boolean;
  children?: ReactNode;
}) {
  return (
    <View style={{ gap: 8 }}>
      {title ? <ThemedText type="subtitle">{title}</ThemedText> : null}
      {children}
      {separator ? (
        <View
          style={{
            alignSelf: "stretch",
            borderBottomWidth: StyleSheet.hairlineWidth,
            borderBottomColor: "#E4E6EB",
            marginVertical: 4,
          }}
        />
      ) : null}
    </View>
  );
}
