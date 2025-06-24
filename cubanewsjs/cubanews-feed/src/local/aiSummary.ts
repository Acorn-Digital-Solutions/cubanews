import cubanewsApp from "@/app/cubanewsApp";

function main() {
  // const __dirname = path.dirname(fileURLToPath(import.meta.url));
  // const modelPath = path.join(
  //   __dirname,
  //   "models",
  //   "hf_mradermacher_Llama-3.2-3B-Instruct.Q8_0.gguf"
  // );
  // const cubanewsAiAssistant = new CubanewsAiAssistant(modelPath);
  // cubanewsAiAssistant.initialise().then(async () => {
  //   const feedItems = await cubanewsApp.getFeedItems();
  //   console.log(feedItems);
  //   const summary = await cubanewsAiAssistant.generateAiFeedSummary(feedItems);
  //   console.log("Feed summary,", summary);

  //   feedItems.map(async (item) => {
  //     item.aiSummary = await cubanewsAiAssistant.generateArticleSummary(
  //       item.content
  //     );
  //   });
  //   console.log(feedItems);
  // });
  cubanewsApp.getAiAssistant().then(async (cubanewsAiAssistant) => {
    const feedItems = await cubanewsApp.getFeedItems();
    // console.log(feedItems);
    // const summary = await cubanewsAiAssistant.generateAiFeedSummary(feedItems);
    // console.log("Feed summary,", summary);
    for (const item of feedItems) {
      const aiSummary = await cubanewsAiAssistant.generateArticleSummary(
        item.content
      );
      console.log(aiSummary);
    }
    // const updatedFeedItems = feedItems.map(async (item) => {
    //   const aiSummary = await cubanewsAiAssistant.generateArticleSummary(
    //     item.content
    //   );
    //   return { ...item, aiSummary: aiSummary };
    // });
    // console.log(updatedFeedItems);
  });
}

main();
