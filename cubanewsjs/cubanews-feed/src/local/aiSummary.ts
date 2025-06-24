import cubanewsApp from "@/app/cubanewsApp";

function main() {
  cubanewsApp.getAiAssistant().then(async (cubanewsAiAssistant) => {
    const feedItems = await cubanewsApp.getFeedItems();
    for (const item of feedItems) {
      const aiSummary = await cubanewsAiAssistant.generateArticleSummary(
        item.content
      );
      console.log(aiSummary);
    }
  });
}

main();
