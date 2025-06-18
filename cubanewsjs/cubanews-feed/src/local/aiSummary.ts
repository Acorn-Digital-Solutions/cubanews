import { fileURLToPath } from "url";
import {
  getLlama,
  Llama,
  LlamaChatSession,
  LlamaGrammar,
  LlamaModel,
} from "node-llama-cpp";
import path from "path";
import { NewsItem } from "@/app/interfaces";
import { generateAISummary, getFeedItems } from "./mailSender";
import cubanewsApp from "@/app/cubanewsApp";

export class CubanewsAiAssistant {
  __dirname = path.dirname(fileURLToPath(import.meta.url));
  model: LlamaModel | undefined;

  constructor() {}

  async initialise() {
    const llama = await getLlama();
    this.model = await llama.loadModel({
      modelPath: path.join(
        __dirname,
        "models",
        "hf_mradermacher_Llama-3.2-3B-Instruct.Q8_0.gguf"
      ),
    });
  }

  async generateArticleSummary(fullContent: string): Promise<string> {
    if (this.model) {
      const context = await this.model.createContext();
      const session = new LlamaChatSession({
        contextSequence: context.getSequence(),
      });
      const summary = await session.prompt(
        "En espanol, resumen en 100 palabras el siguiente texto: " + fullContent
      );
      return summary;
    }
    throw new Error("Ai assistant not initialised");
  }
}

async function aiHelloMessage(): Promise<string> {
  // Here you would typically call an AI service to generate a summary.
  // For simplicity, we will just return a placeholder text.

  const __dirname = path.dirname(fileURLToPath(import.meta.url));
  const llama = await getLlama();
  const model = await llama.loadModel({
    modelPath: path.join(
      __dirname,
      "models",
      "hf_mradermacher_Llama-3.2-3B-Instruct.Q8_0.gguf"
    ),
  });
  const context = await model.createContext();
  const session = new LlamaChatSession({
    contextSequence: context.getSequence(),
  });
  const message = await session.prompt(
    "Habla en Espanol. Saluda a los usuarios"
  );
  return message;
}

export async function generateAiFeedSummary(
  newsItems: NewsItem[]
): Promise<string> {
  const __dirname = path.dirname(fileURLToPath(import.meta.url));
  const llama = await getLlama();
  const model = await llama.loadModel({
    modelPath: path.join(
      __dirname,
      "models",
      "hf_mradermacher_Llama-3.2-3B-Instruct.Q8_0.gguf"
    ),
  });
  const context = await model.createContext();
  const session = new LlamaChatSession({
    contextSequence: context.getSequence(),
  });
  const prompt = newsItems
    .map(
      (newsItem) =>
        `{"titulo": "${newsItem.title}", "contenido": "${newsItem.content}", "url": "${newsItem.url}", "fuente":"${newsItem.source}"}`
    )
    .join(",");
  console.info(prompt);
  const summary = await session.prompt(
    "Crea un resumen de 100 palabras de los siguientes articulos: " +
      prompt +
      ". Incluye el titulo y la fuente de los articulos citados."
  );
  return summary;
}

function main() {
  getFeedItems().then(async (feedItems) => {
    console.log(feedItems);
    const summary = await generateAiFeedSummary(feedItems);
    console.log(summary);
  });
}

main();
