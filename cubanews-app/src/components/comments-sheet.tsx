import { Pressable, ScrollView, StyleSheet, View } from "react-native";
import { ThemedText } from "./themed-text";
import { useTheme } from "@/hooks/use-theme";
import { CNComment } from "@/services/comments-service";

export default function CommentsSheet({
  closeCommentsSheet,
  saveComment,
  deleteComment,
  comments,
  feedItemId,
}: {
  closeCommentsSheet: () => void;
  saveComment: () => void;
  deleteComment: (id: string) => void;
  comments: Array<CNComment>;
  feedItemId: number;
}) {
  const theme = useTheme();
  return (
    <View style={styles.sheetOverlay}>
      <Pressable style={styles.sheetBackdrop} onPress={closeCommentsSheet} />
      <View
        style={[
          styles.sheetContainer,
          {
            backgroundColor: theme.background,
            borderTopColor: theme.backgroundSelected,
          },
        ]}
      >
        <View
          style={[
            styles.sheetHandle,
            { backgroundColor: theme.backgroundSelected },
          ]}
        />

        <ScrollView
          style={styles.sheetScrollView}
          contentContainerStyle={styles.sheetContentContainer}
          showsVerticalScrollIndicator={false}
        >
          {comments.map((comment) => (
            <View
              key={comment.id}
              style={[
                styles.commentRow,
                { borderBottomColor: theme.backgroundSelected },
              ]}
            >
              <View style={styles.commentMetaRow}>
                <ThemedText type="smallBold">{comment.author}</ThemedText>
                <ThemedText type="small" themeColor="textSecondary">
                  {comment.createdAt}
                </ThemedText>
              </View>
              <ThemedText>{comment.content}</ThemedText>
            </View>
          ))}
        </ScrollView>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    padding: 12,
    gap: 8,
    shadowColor: "#000",
    shadowOpacity: 0.2,
    shadowRadius: 1,
    shadowOffset: { width: 0, height: 1 },
    elevation: 2,
  },
  headerRow: {
    alignItems: "center",
    flexDirection: "row",
    justifyContent: "space-between",
  },
  sourceRow: {
    alignItems: "center",
    flexDirection: "row",
    gap: 8,
  },
  sourceBadge: {
    alignItems: "center",
    borderRadius: 4,
    height: 16,
    justifyContent: "center",
    width: 20,
  },
  imagePlaceholder: {
    alignItems: "center",
    borderRadius: 8,
    height: 120,
    justifyContent: "center",
  },
  imageContainer: {
    borderRadius: 8,
    overflow: "hidden",
  },
  image: {
    height: 120,
    width: "100%",
  },
  title: {
    fontSize: 16,
    fontWeight: "600",
    lineHeight: 22,
  },
  separator: {
    height: 1,
    marginVertical: 4,
  },
  actionRow: {
    alignItems: "center",
    flexDirection: "row",
    gap: 20,
  },
  actionSpacer: {
    flex: 1,
  },
  sheetOverlay: {
    flex: 1,
    justifyContent: "flex-end",
  },
  sheetBackdrop: {
    position: "absolute",
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    backgroundColor: "rgba(0, 0, 0, 0.3)",
  },
  sheetContainer: {
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    borderTopWidth: 1,
    paddingHorizontal: 16,
    paddingTop: 8,
    paddingBottom: 20,
    height: "80%",
  },
  sheetHandle: {
    width: 44,
    height: 4,
    borderRadius: 4,
    alignSelf: "center",
    marginBottom: 12,
  },
  sheetHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 12,
  },
  sheetScrollView: {
    flex: 1,
  },
  sheetContentContainer: {
    paddingBottom: 8,
  },
  commentRow: {
    paddingVertical: 12,
    borderBottomWidth: StyleSheet.hairlineWidth,
    gap: 6,
  },
  commentMetaRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    gap: 8,
  },
});
