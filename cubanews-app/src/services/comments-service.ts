import {
  FirebaseApp,
  FirebaseOptions,
  getApp,
  getApps,
  initializeApp,
} from "firebase/app";
import { addDoc, collection, getFirestore } from "firebase/firestore";

type CNComment = {
  id: string;
  feedItemId: number;
  content: string;
  author: string;
  createdAt: number;
};

type AddCommentParams = {
  feedItemId: number;
  content: string;
  author: string;
};

class CommentsService {
  private readonly firebaseApp: FirebaseApp | null;

  constructor() {
    this.firebaseApp = this.createFirebaseApp();
  }

  async addComment({
    feedItemId,
    content,
    author,
  }: AddCommentParams): Promise<CNComment> {
    const normalizedContent = content.trim();
    const normalizedAuthor = author.trim();

    if (!Number.isFinite(feedItemId) || feedItemId <= 0) {
      throw new Error("feedItemId must be a positive number.");
    }

    if (!normalizedContent) {
      throw new Error("Comment content cannot be empty.");
    }

    if (!normalizedAuthor) {
      throw new Error("Comment author cannot be empty.");
    }

    if (!this.firebaseApp) {
      throw new Error(
        "Firebase is not configured. Set EXPO_PUBLIC_FIREBASE_* environment variables.",
      );
    }

    const createdAt = Date.now();
    const db = getFirestore(this.firebaseApp);
    const commentToCreate = {
      feedItemId,
      content: normalizedContent,
      author: normalizedAuthor,
      createdAt,
    };

    const docRef = await addDoc(collection(db, "comments"), commentToCreate);

    return {
      id: docRef.id,
      ...commentToCreate,
    };
  }

  private createFirebaseApp(): FirebaseApp | null {
    const config = this.getFirebaseConfig();
    if (!config) {
      return null;
    }

    if (getApps().length > 0) {
      return getApp();
    }

    return initializeApp(config);
  }

  private getFirebaseConfig(): FirebaseOptions | null {
    const {
      EXPO_PUBLIC_FIREBASE_API_KEY,
      EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN,
      EXPO_PUBLIC_FIREBASE_PROJECT_ID,
      EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET,
      EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
      EXPO_PUBLIC_FIREBASE_APP_ID,
    } = process.env;

    if (
      !EXPO_PUBLIC_FIREBASE_API_KEY ||
      !EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN ||
      !EXPO_PUBLIC_FIREBASE_PROJECT_ID ||
      !EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET ||
      !EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID ||
      !EXPO_PUBLIC_FIREBASE_APP_ID
    ) {
      return null;
    }

    return {
      apiKey: EXPO_PUBLIC_FIREBASE_API_KEY,
      authDomain: EXPO_PUBLIC_FIREBASE_AUTH_DOMAIN,
      projectId: EXPO_PUBLIC_FIREBASE_PROJECT_ID,
      storageBucket: EXPO_PUBLIC_FIREBASE_STORAGE_BUCKET,
      messagingSenderId: EXPO_PUBLIC_FIREBASE_MESSAGING_SENDER_ID,
      appId: EXPO_PUBLIC_FIREBASE_APP_ID,
    };
  }
}

const commentsService = new CommentsService();

export { commentsService, CommentsService };
export type { AddCommentParams, CNComment };
