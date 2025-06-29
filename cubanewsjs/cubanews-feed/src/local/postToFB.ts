import { FacebookAdsApi, Page } from "facebook-nodejs-business-sdk";
import moment from "moment";
import "moment/locale/es"; // Import Spanish locale
import cubanewsApp from "@/app/cubanewsApp";
import { NewsItem } from "@/app/interfaces";

// Set the locale to Spanish
moment.locale("es");

async function getPageFeed() {
  const accessToken = process.env.ACCESS_TOKEN;
  const pageId = process.env.PAGE_ID;
  if (accessToken) {
    FacebookAdsApi.init(accessToken);
    const page = new Page(pageId);
    const feed = await page.getFeed([], {
      access_token: accessToken,
    });
    return feed;
  }
  return "";
}

async function postToCubanewsFacebookPage(
  postContent: string,
  link: string = ""
): Promise<string> {
  const accessToken = process.env.ACCESS_TOKEN;
  const pageId = process.env.PAGE_ID;
  if (!accessToken) {
    console.error("No access token provided.");
    return "";
  }
  FacebookAdsApi.init(accessToken);
  const page = new Page(pageId);
  const result = await page.createFeed([], {
    message: postContent,
    link: link,
    access_token: accessToken,
  });
  return result.id;
}

function main(dryRun = false) {
  console.log("Initiating Post to FB");
  console.log("Dry Run", dryRun);
  const formattedDate = moment().format("dddd D [de] MMMM YYYY");
  const capitalized =
    formattedDate.charAt(0).toUpperCase() + formattedDate.slice(1);
  cubanewsApp
    .getFBPostNewsItems()
    .then(async (newsItems: NewsItem[]) => {
      const postHeader = `Titulares, ${capitalized}`;
      const postBody = newsItems
        .map((item) => `${item.title} [${item.url}]\n`)
        .join("\n");
      const postFooter = "Ver más en https://cubanews.icu";
      const postContent = `${postHeader}\n\n${postBody}\n${postFooter}`;
      console.log(
        `-----------------------\n${postContent}\n-----------------------`
      );
      if (!dryRun) {
        const postId = await postToCubanewsFacebookPage(
          postContent,
          newsItems[0].url
        );
        console.log("Created post: ", postId);
      }
    })
    .catch((error: any) => {
      console.error("Failed to retrieve feed, Error: ", error);
    });
}

const args = process.argv.slice(2); // skip node and script path
const dryRun = args.includes("--dry-run");

main(dryRun);
