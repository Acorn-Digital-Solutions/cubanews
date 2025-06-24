import { LlamaModel, getLlama, LlamaChatSession } from "node-llama-cpp";
import { NewsItem } from "../interfaces";

export class CubanewsAiAssistant {
  private model: LlamaModel | undefined;

  constructor(private modelPath: string) {}

  async initialise() {
    const llama = await getLlama();
    this.model = await llama.loadModel({
      modelPath: this.modelPath,
    });
  }

  async generateArticleSummary(
    fullContent: string | undefined | null
  ): Promise<string> {
    if (!fullContent) {
      throw new Error("Content to summarise is undefined");
    }
    if (this.model) {
      const context = await this.model.createContext();
      const session = new LlamaChatSession({
        contextSequence: context.getSequence(),
      });
      const prompt =
        "En espanol, resume en 100 palabras el siguiente texto: " + fullContent;
      console.log(prompt);
      const summary = await session.prompt(prompt);
      await context.dispose();
      return summary;
    }
    throw new Error("Ai assistant not initialised");
  }

  async generateAiFeedSummary(newsItems: NewsItem[]): Promise<string> {
    if (this.model) {
      const context = await this.model.createContext();
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
        "Crea un resumen de 300 palabras de los siguientes articulos: " +
          prompt +
          ". Incluye el titulo y la fuente de los articulos citados."
      );
      return summary;
    }
    throw new Error("Ai assistant not initialised");
  }
}
