import React, { useState } from "react";
import {
  Pressable,
  ScrollView,
  StyleSheet,
  TextInput,
  TextInputContentSizeChangeEvent,
  View,
} from "react-native";
import { MaterialDesignIcons } from "@react-native-vector-icons/material-design-icons";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { ThemedText } from "./themed-text";
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
  const insets = useSafeAreaInsets();
  const [_comments, _setComments] = useState(comments);
  const [commentText, setCommentText] = useState("");
  const hasComments = _comments.length > 0;

  return (
    <View style={styles.sheetOverlay}>
      <Pressable style={styles.sheetBackdrop} onPress={closeCommentsSheet} />
      <View
        style={[
          styles.sheetContainer,
          {
            backgroundColor: "#FFFFFF",
            borderTopColor: "#E4E6EB",
          },
        ]}
      >
        <View style={[styles.sheetHandle, { backgroundColor: "#BCC0C4" }]} />

        <View style={styles.sheetBody}>
          <ScrollView
            style={styles.sheetScrollView}
            contentContainerStyle={[
              styles.sheetContentContainer,
              !hasComments && styles.emptyContentContainer,
            ]}
            showsVerticalScrollIndicator={false}
          >
            {hasComments ? (
              _comments.map((comment) => (
                <View
                  key={comment.id}
                  style={[styles.commentRow, { borderBottomColor: "#E4E6EB" }]}
                >
                  <View style={styles.commentMetaRow}>
                    <ThemedText type="smallBold">{comment.author}</ThemedText>
                    <ThemedText type="small" themeColor="textSecondary">
                      {comment.createdAt}
                    </ThemedText>
                  </View>
                  <ThemedText>{comment.content}</ThemedText>
                </View>
              ))
            ) : (
              <View style={styles.emptyStateWrapper}>
                <MaterialDesignIcons
                  name="comment-outline"
                  size={72}
                  color="#DADDE1"
                />
                <View style={styles.emptyStateTextWrapper}>
                  <ThemedText style={styles.emptyTitle}>
                    No comments yet
                  </ThemedText>
                  <ThemedText style={styles.emptySubtitle}>
                    Be the first to comment.
                  </ThemedText>
                </View>
              </View>
            )}
          </ScrollView>

          <View
            style={[
              styles.commentInputSection,
              {
                borderTopColor: "#E4E6EB",
                paddingBottom: Math.max(insets.bottom, 8),
              },
            ]}
          >
            <View style={styles.commentComposerPill}>
              <TextInput
                style={[styles.commentTextInput]}
                placeholder="Comment as @username"
                placeholderTextColor="#65676B"
                value={commentText}
                onChangeText={setCommentText}
                onContentSizeChange={(
                  _event: TextInputContentSizeChangeEvent,
                ) => {}}
                multiline
                scrollEnabled={false}
              />
            </View>
            <Pressable
              style={styles.inputActionIcon}
              onPress={() => {
                const normalizedText = commentText.trim();
                if (!normalizedText) {
                  return;
                }

                const nextComments = [
                  ..._comments,
                  {
                    id: String(Date.now()),
                    feedItemId,
                    content: normalizedText,
                    author: "Autor",
                    createdAt: Date.now(),
                  } as CNComment,
                ];
                _setComments(nextComments);
                setCommentText("");
              }}
              hitSlop={10}
            >
              <MaterialDesignIcons name="send" size={28} />
            </Pressable>
          </View>
        </View>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
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
    backgroundColor: "rgba(0, 0, 0, 0.24)",
  },
  sheetContainer: {
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    borderTopWidth: 1,
    height: "82%",
    overflow: "hidden",
  },
  sheetHandle: {
    width: 52,
    height: 5,
    borderRadius: 999,
    alignSelf: "center",
    marginTop: 10,
    marginBottom: 12,
  },
  sheetBody: {
    flex: 1,
  },
  sheetScrollView: {
    flex: 1,
  },
  sheetContentContainer: {
    paddingHorizontal: 16,
    paddingBottom: 12,
  },
  emptyContentContainer: {
    flexGrow: 1,
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
  emptyStateWrapper: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingBottom: 80,
    gap: 12,
  },
  emptyStateTextWrapper: {
    alignItems: "center",
  },
  emptyTitle: {
    color: "#606770",
    fontSize: 22,
    lineHeight: 30,
    fontWeight: "700",
  },
  emptySubtitle: {
    color: "#606770",
    fontSize: 18,
    lineHeight: 26,
    fontWeight: "500",
  },
  commentInputSection: {
    flexDirection: "row",
    alignItems: "flex-end",
    justifyContent: "space-between",
    borderTopWidth: StyleSheet.hairlineWidth,
    paddingHorizontal: 12,
    paddingTop: 10,
    backgroundColor: "#FFFFFF",
  },
  commentComposerPill: {
    flex: 1,
    maxHeight: 140,
    borderRadius: 26,
    backgroundColor: "#EDEFF3",
    flexDirection: "row",
    alignItems: "flex-start",
    paddingHorizontal: 16,
    paddingVertical: 14,
  },
  commentInputWrapper: {
    flex: 1,
  },
  commentTextInput: {
    flexGrow: 1,
    flexShrink: 1,
    minHeight: 22,
    color: "#1C1E21",
    fontSize: 16,
    lineHeight: 22,
    paddingVertical: 0,
    textAlignVertical: "top",
    includeFontPadding: false,
  },
  inputActionIcon: {
    paddingLeft: 5,
    paddingBottom: 10,
    alignItems: "center",
    justifyContent: "center",
  },
});
