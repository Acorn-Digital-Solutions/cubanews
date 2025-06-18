# Cubanews Crawler

Implemented using Crawlee + PlaywrightCrawler + TypeScript

This is a general project that depending on input it will crawl one of the news sources.

## Setting news source input

Edit the value of `storage/key_value_stores/default/INPUT.json`, for instance

```
{
  "source": "adncuba"
}
```

## Building the project

```bash
npm install
npm run build
```

## Running for dev

```bash
npm start
```

This sets the environment variable `NODE_ENV` to `dev` which will cause the crawler to run on local mode, meaning it will not call `Actor.init()`
Either way the result of the crawl will be persisted to `storage/dataset`

## Deploying

apify init will create the .actor folder if it doesn't exist. It will also reset the storage folder.

```bash
apify init
apify push
```

## Adding a new crawler

1. Create a new file called `<source>Crawler.ts`
2. Add an entry for the news source to `NewsSourceName`
3. Implement your crawler class

```typescript
const newsSource = getNewsSourceByName(NewsSourceName.ADNCUBA);
export default class SourceNameCrawler extends CubanewsCrawler {
  constructor() {
    super(newsSource);
  }

  override async requestHandler(
    context: PlaywrightCrawlingContext
  ): Promise<void> {
    ...
  }
}
```

4. Add a new entry to the switch case in `main.ts`

## More examples of Crawlee

- [Documentation](https://crawlee.dev/api/playwright-crawler/class/PlaywrightCrawler)
- [Examples](https://crawlee.dev/docs/examples/playwright-crawler)
