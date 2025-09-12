import "server-only";

import cubanewsApp from "@/app/cubanewsApp";
import {
  generateArticleSummary,
  initialise,
} from "@/app/ai/cubanewsAiAssistant";
import path from "path";
import { fileURLToPath } from "url";

const dirname = path.dirname(fileURLToPath(import.meta.url));

function main() {
  const modelPath = path.join(
    dirname,
    "ai/models",
    "hf_mradermacher_Llama-3.2-3B-Instruct.Q8_0.gguf"
  );
  initialise(modelPath).then(async (model) => {
    const feedItems = await cubanewsApp.getFeedItems();
    for (const item of feedItems) {
      const aiSummary = await generateArticleSummary(model, item.content);
      console.log(aiSummary);
    }
  });
}

main();
