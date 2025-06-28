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
) {
  const accessToken = process.env.ACCESS_TOKEN;
  const pageId = process.env.PAGE_ID;
  if (!accessToken) {
    return;
  }
  FacebookAdsApi.init(accessToken);
  const page = new Page(pageId);
  const result = await page.createFeed([], {
    message: postContent,
    link: link,
    access_token: accessToken,
  });
  return result;
}

function main() {
  cubanewsApp
    .getFeedItems()
    .then(async (newsItems: NewsItem[]) => {})
    .catch((error: any) => {
      console.error("Failed to retrieve feed, Error: ", error);
    });

  // getPageFeed().then((feed) => console.log("Page feed: ", feed));

  // postToCubanewsFacebookPage("Post de prueba")
  //   .then((result) => console.log("Posted successfully ", result))
  //   .catch((error) => console.error(error));

  // Format the date
  const formattedDate = moment().format("dddd D [de] MMMM YYYY");
  // Capitalize the first letter
  const capitalized =
    formattedDate.charAt(0).toUpperCase() + formattedDate.slice(1);
  const postContent = `Titulares, ${capitalized}

https://www.cibercuba.com/noticias/2025-06-28-u1-e42839-s27061-nid305884-youtuber-cubano-uruguay-detalla-sus-gastos-mensuales \n

https://diariodecuba.com/cuba/1751065499_61783.html \n

Ver más en https://cubanews.icu`;

  postToCubanewsFacebookPage(
    postContent,
    "https://diariodecuba.com/cuba/1751065499_61783.html"
  );
}

main();
