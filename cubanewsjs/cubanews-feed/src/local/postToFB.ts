import { FacebookAdsApi, Page } from "facebook-nodejs-business-sdk";
import moment from "moment";
import "moment/locale/es"; // Import Spanish locale
import cubanewsApp from "@/app/cubanewsApp";
import { NewsItem } from "@/app/interfaces";
import { chromium, Browser, Page as PlaywrightPage } from "playwright";
import * as fs from "fs";

// Set the locale to Spanish
moment.locale("es");

const accessToken = process.env.PAGE_ACCESS_TOKEN;
const pageId = process.env.PAGE_ID;
const fbEmail = process.env.FB_EMAIL;
const fbPassword = process.env.FB_PASSWORD;

async function getPageFeed() {
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
    published: true,
  });
  return result.id;
}

async function postUsingPlayright(headless: boolean = true) {
  if (!fbEmail || !fbPassword) {
    console.error(
      "Facebook email or password not provided in environment variables."
    );
    return;
  }

  let browser: Browser | null = null;

  try {
    console.log(
      `Launching browser in ${headless ? "headless" : "headed"} mode...`
    );
    browser = await chromium.launch({
      headless: headless,
      slowMo: headless ? 0 : 100, // Slow down actions when visible for easier viewing
    });

    const context = await browser.newContext({
      viewport: { width: 1280, height: 720 },
      userAgent:
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    });

    const page = await context.newPage();
    // Navigate to Facebook
    console.log("Navigating to Facebook...");
    await page.goto("https://www.facebook.com/", {
      waitUntil: "load",
      timeout: 30000,
    });

    // Check if we're already logged in by looking for login form
    const currentUrl = page.url();
    console.log("Current URL after navigation:", currentUrl);

    const loginFormExists =
      (await page.locator('input[name="email"]').count()) > 0;
    const isLoggedIn = !loginFormExists;
    console.log("Login form exists:", loginFormExists);
    console.log("Is logged in:", isLoggedIn);
    if (!isLoggedIn) {
      console.log("Not logged in, proceeding with login...");

      // Handle cookie consent if present
      try {
        await page.waitForSelector('button:has-text("Allow all cookies")', {
          timeout: 3000,
        });
        await page.click('button:has-text("Allow all cookies")');
        console.log("Accepted cookies");
      } catch (e) {
        console.log("No cookie banner found or already accepted");
      }

      // Fill in login credentials
      console.log("Logging in...");
      await page.fill('input[name="email"]', fbEmail);
      await page.fill('input[name="pass"]', fbPassword);

      // Click login button
      await page.click('button[name="login"]');

      // Wait for navigation after login - use load instead of networkidle
      console.log("Waiting for login to complete...");
      try {
        await page.waitForURL((url) => !url.toString().includes("/login"), {
          timeout: 15000,
        });
      } catch (e) {
        // Fallback: just wait for load state
        await page.waitForLoadState("load", { timeout: 15000 });
      }

      // Give it a moment to settle
      await page.waitForTimeout(3000);

      // Check if login was successful
      const currentUrl = page.url();
      console.log("URL after login attempt:", currentUrl);
      if (currentUrl.includes("login") || currentUrl.includes("checkpoint")) {
        console.error("Login failed or requires additional verification");
        // Take a screenshot for debugging
        await page.screenshot({ path: "login-failed.png" });
        return;
      }
      console.log("Login successful!");
    } else {
      console.log("Already logged in using saved cookies!");
    }

    // Navigate to the Facebook Business page
    console.log("Navigating to Facebook Business page...");
    await page.goto(
      "https://business.facebook.com/latest/composer/?asset_id=102201022455326&business_id=335961798794797&context_ref=HOME&nav_ref=internal_nav&ref=biz_web_home_create_post",
      { waitUntil: "networkidle" }
    );

    console.log("Successfully navigated to Facebook Business page");

    // Wait for the composer to load
    console.log("Waiting for post composer...");
    await page.waitForTimeout(3000);

    // Find and fill the contenteditable text area
    console.log("Looking for text field...");
    const textField = page
      .locator('div[contenteditable="true"][role="combobox"]')
      .first();
    await textField.waitFor({ state: "visible", timeout: 10000 });

    // Create the post content
    const newsItems = await cubanewsApp.getFBPostNewsItems();
    if (newsItems.length === 0) {
      console.error("No news items available to post.");
      return;
    }

    const formattedDate = moment().format("dddd D [de] MMMM YYYY");
    const capitalized =
      formattedDate.charAt(0).toUpperCase() + formattedDate.slice(1);
    const postHeader = `Titulares, ${capitalized}`;
    const postBody = newsItems
      .map((item) => `${item.title} [${item.url}]\n`)
      .join("\n");
    const postFooter = "Ver más en https://cubanews.icu";
    const postContent = `${postHeader}\n\n${postBody}\n${postFooter}`;
    console.log(
      `-----------------------\n${postContent}\n-----------------------`
    );
    console.log("Filling post content...");

    await textField.fill(postContent);
    // Wait a bit to see the content
    await page.waitForTimeout(2000);

    // Find and click the publish button
    console.log("Looking for publish button...");
    const publishButton = page
      .locator('div[role="button"]:has-text("Publish to Facebook")')
      .first();
    await publishButton.waitFor({ state: "visible", timeout: 10000 });

    console.log("Clicking publish button...");
    await publishButton.click();

    console.log("Post published!");

    // Wait to see the result
    await page.waitForTimeout(5000);

    // Wait a bit to see the page (useful when not headless)
    if (!headless) {
      console.log(
        "Waiting 60 seconds before closing browser (or close manually)..."
      );
      try {
        await page.waitForTimeout(10000);
      } catch (e) {
        console.log("Browser was closed manually");
      }
    }

    // Take a screenshot for confirmation
    try {
      await page.screenshot({ path: "facebook-business-page.png" });
      console.log("Screenshot saved as facebook-business-page.png");
    } catch (e) {
      console.log("Could not save screenshot (browser may be closed)");
    }
  } catch (error) {
    console.error("Error during Playwright automation:", error);
    // Don't throw on manual browser close
    if (error instanceof Error && error.message.includes("closed")) {
      console.log("Browser was closed, exiting gracefully");
      return;
    }
    throw error;
  } finally {
    if (browser) {
      await browser.close();
      console.log("Browser closed");
    }
  }
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
        ).catch((reason) => console.error(reason));
        console.log("Created post: ", postId);
      }
    })
    .catch((error: any) => {
      console.error("Failed to retrieve feed, Error: ", error);
    });
}

const args = process.argv.slice(2); // skip node and script path
const dryRun = args.includes("--dry-run");
const usePlaywright = args.includes("--playwright");
const headless = !args.includes("--headed"); // headless by default, use --headed to show browser

if (usePlaywright) {
  // Use Playwright to automate posting
  postUsingPlayright(headless)
    .then(() => {
      console.log("Playwright automation completed");
    })
    .catch((error) => {
      console.error("Playwright automation failed:", error);
      process.exit(1);
    });
} else {
  // Use the API-based posting
  main(dryRun);
}
