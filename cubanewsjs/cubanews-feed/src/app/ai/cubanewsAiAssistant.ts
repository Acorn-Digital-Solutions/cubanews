"use server";

import { LlamaModel, getLlama, LlamaChatSession } from "node-llama-cpp";
import { NewsItem } from "../interfaces";

export async function initialise(modelPath: string): Promise<LlamaModel> {
  const llama = await getLlama();
  return await llama.loadModel({
    modelPath: modelPath,
  });
}

export async function generateArticleSummary(
  model: LlamaModel,
  fullContent: string | undefined | null
): Promise<string> {
  if (!fullContent) {
    throw new Error("Content to summarise is undefined");
  }
  if (model) {
    const context = await model.createContext();
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

export async function generateAiFeedSummary(
  model: LlamaModel,
  newsItems: NewsItem[]
): Promise<string> {
  if (model) {
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
      "Crea un resumen de 300 palabras de los siguientes articulos: " +
        prompt +
        ". Incluye el titulo y la fuente de los articulos citados."
    );
    return summary;
  }
  throw new Error("Ai assistant not initialised");
}
