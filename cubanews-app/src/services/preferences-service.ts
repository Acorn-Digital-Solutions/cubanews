import { NewsSourceName } from "@/models/feed-model";

const VALID_SOURCES = new Set(Object.values(NewsSourceName));

class PreferencesService {
  async pushPreferredSources(preferredSources: NewsSourceName[]): Promise<void> {
    const normalizedSources = [...new Set(preferredSources)];

    if (
      normalizedSources.some((sourceName) => !VALID_SOURCES.has(sourceName))
    ) {
      throw new Error("Preferred sources contain an unsupported source.");
    }

    // Placeholder until preferences are stored in Firebase for the signed-in user.
    return Promise.resolve();
  }
}

const preferencesService = new PreferencesService();

export { preferencesService, PreferencesService };
