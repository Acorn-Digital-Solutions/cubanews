# Facebook Post Automation

This script provides two methods for posting to Facebook:

## 1. API-based Posting (Original Method)

Uses the Facebook Graph API to post directly to the page.

### Required Environment Variables

- `PAGE_ACCESS_TOKEN` - Your Facebook Page access token
- `PAGE_ID` - Your Facebook Page ID

### Usage

```bash
# Dry run (preview post without actually posting)
npm run start:postToFB:dev -- --dry-run

# Actual posting
npm run start:postToFB:dev
```

## 2. Playwright Automation (New Method)

Uses Playwright to automate browser interactions with Facebook Business Manager.

### Required Environment Variables

- `FB_EMAIL` - Your Facebook account email
- `FB_PASSWORD` - Your Facebook account password

### Usage

#### Headless Mode (default)

Runs the browser in the background without displaying the UI:

```bash
npm run start:postToFB:playwright:dev
```

#### Headed Mode (visible browser)

Shows the browser window so you can see what's happening:

```bash
npm run start:postToFB:playwright:headed
```

#### Manual Command

You can also run it manually with custom flags:

```bash
# Headless mode
ENV_FILE='.env.development.local' tsx src/local/postToFB.ts -- --playwright

# Headed mode (show browser)
ENV_FILE='.env.development.local' tsx src/local/postToFB.ts -- --playwright --headed
```

## Environment Setup

1. Copy `.env.example` to `.env.development.local`:

   ```bash
   cp .env.example .env.development.local
   ```

2. Fill in your credentials in `.env.development.local`

## Features

### Playwright Mode

- Logs into Facebook using username/password
- Navigates to Facebook Business Manager
- Takes screenshots for debugging
- Handles cookie consent banners
- Provides detailed console logging
- Supports both headless and headed modes

### Notes

- Screenshots are saved in the project root as `facebook-business-page.png`
- If login fails, a `login-failed.png` screenshot is saved for debugging
- The headed mode runs slower to make actions visible
- Facebook may require additional verification (2FA) which will need manual intervention
