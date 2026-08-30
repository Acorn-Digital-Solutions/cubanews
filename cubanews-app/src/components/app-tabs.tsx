import { NativeTabs } from "expo-router/unstable-native-tabs";
import { useColorScheme } from "react-native";
import { MaterialDesignIcons } from "@react-native-vector-icons/material-design-icons";

import { Colors } from "@/constants/theme";

export default function AppTabs() {
  const scheme = useColorScheme();
  const colors = Colors[scheme === "unspecified" ? "light" : scheme];

  return (
    <NativeTabs
      backgroundColor={colors.background}
      indicatorColor={colors.backgroundElement}
      iconColor={{ default: colors.textSecondary, selected: colors.text }}
      labelStyle={{ selected: { color: colors.text } }}
    >
      <NativeTabs.Trigger name="index" disableAutomaticContentInsets>
        <NativeTabs.Trigger.Label>Titulares</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          src={
            <NativeTabs.Trigger.VectorIcon
              family={MaterialDesignIcons}
              name="newspaper-variant"
            />
          }
        />
      </NativeTabs.Trigger>
      <NativeTabs.Trigger name="social" disableAutomaticContentInsets>
        <NativeTabs.Trigger.Label>Social</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          src={
            <NativeTabs.Trigger.VectorIcon
              family={MaterialDesignIcons}
              name="account-group"
            />
          }
        />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="services" disableAutomaticContentInsets>
        <NativeTabs.Trigger.Label>Servicios</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          src={
            <NativeTabs.Trigger.VectorIcon
              family={MaterialDesignIcons}
              name="briefcase"
            />
          }
        />
      </NativeTabs.Trigger>

      <NativeTabs.Trigger name="profile" disableAutomaticContentInsets>
        <NativeTabs.Trigger.Label>Perfil</NativeTabs.Trigger.Label>
        <NativeTabs.Trigger.Icon
          src={
            <NativeTabs.Trigger.VectorIcon
              family={MaterialDesignIcons}
              name="account"
            />
          }
        />
      </NativeTabs.Trigger>
    </NativeTabs>
  );
}
