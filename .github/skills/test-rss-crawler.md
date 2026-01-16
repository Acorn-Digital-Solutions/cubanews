# RSS Crawler Testing and Debugging Skill

## Purpose

This skill helps test and debug RSS crawlers for Cubanews, including CatorceYMedio, Cibercuba, and DirectorioCubano RSS feeds.

## When to Use

- Testing RSS feed parsing and image extraction
- Debugging RSS crawler issues
- Validating new RSS crawler implementations
- Verifying RSS feed structure changes

## Available RSS Crawlers

1. **CatorceYMedioRSSCrawler** - RSS feed from 14yMedio (https://www.14ymedio.com/rss/)
2. **CibercubaRSSCrawler** - RSS feed from Cibercuba (https://www.cibercuba.com/noticias/cibercuba/rss.xml)
3. **DirectorioCubanoRSSCrawler** - RSS feed from Directorio Cubano (https://www.directoriocubano.info/feed/)

## Test File Location

`/Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed/test-rss.ts`

## How to Run Tests

### Basic Test Command

```bash
cd /Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed
npm run test-rss-crawler
```

### Test Different Crawlers

Edit `test-rss.ts` to test different crawlers:

```typescript
// Test CatorceYMedio
const crawler = new CatorceYMedioRSSCrawler();

// Test Cibercuba
const crawler = new CibercubaRSSCrawler();

// Test Directorio Cubano
const crawler = new DirectorioCubanoRSSCrawler();
```

### Test Parameters

- `uploadImages`: Set to `false` for testing without uploading to Firebase
- `limit`: Number of articles to fetch (default: 50)

```typescript
crawler.getRSSContent(false, 10); // Test 10 articles without uploading images
```

## Common Debugging Steps

### 1. Check RSS Feed Accessibility

```bash
curl -I "https://www.directoriocubano.info/feed/"
```

### 2. Verify Image Extraction

- Check the `tryGetMediaImage()` method implementation
- RSS feeds use different formats:
  - **CatorceYMedio**: Uses `media:content` and `media:thumbnail` fields
  - **Cibercuba**: Uses `enclosure` field
  - **Directorio Cubano**: Embeds images in HTML within `description` field

### 3. Test Output Structure

The crawler should return `RSSArticle[]` with:

```typescript
{
  title: string
  link: string
  pubDate: string
  author: string
  categories: string[]
  contentSnippet: string
  content: string
  guid: string
  isoDate: string
  image: string | null  // Firebase storage path
}
```

### 4. Check Parser Configuration

Each crawler has custom parser fields:

- Verify `customFields` match RSS feed structure
- Check `headers` for User-Agent and Accept types
- Validate RSS feed URL is correct

### 5. Firebase Storage Issues

- If images aren't uploading, check Firebase config
- Verify storage bucket permissions
- Check if emulator is needed: `FIREBASE_EMULATOR=true`

## Troubleshooting Guide

### Issue: "Cannot find module" errors

**Solution**: Check imports in test-rss.ts use correct path alias:

```typescript
import { CrawlerName } from "@/app/cubanewsRSSCrawler";
```

### Issue: No images extracted

**Solution**:

1. Check RSS feed structure with curl or browser
2. Verify `tryGetMediaImage()` regex/logic matches feed format
3. Test with `uploadImages: false` to isolate issue

### Issue: Parser errors

**Solution**:

1. Validate RSS feed XML is well-formed
2. Check `customFields` configuration matches feed namespaces
3. Verify headers include proper User-Agent

### Issue: Rate limiting or blocked requests

**Solution**:

1. Check User-Agent header is set correctly
2. Add delays between requests if testing multiple items
3. Verify source website hasn't blocked the IP

## Code Structure Reference

### Base Class

`CubanewsRSSCrawler` - Abstract base class in `cubanewsRSSCrawler.ts`

### Required Implementation

Each crawler must implement:

```typescript
override tryGetMediaImage(item: any): string | null {
  // Extract image URL from RSS item
  // Return null if no image found
}
```

### Constructor Pattern

```typescript
constructor(storage?: FirebaseStorage) {
  super(
    {
      name: NewsSourceName.XXX,
      startUrls: new Set(["https://..."]),
      rssFeed: "https://...",
      datasetName: NewsSourceName.XXX + "-dataset",
      parser: new Parser({
        customFields: { /* ... */ },
        headers: { /* ... */ }
      })
    },
    storage
  );
}
```

## Quick Test Examples

### Test All Crawlers

```typescript
async function testAllCrawlers() {
  const crawlers = [
    new CatorceYMedioRSSCrawler(),
    new CibercubaRSSCrawler(),
    new DirectorioCubanoRSSCrawler(),
  ];

  for (const crawler of crawlers) {
    console.log(`\n=== Testing ${crawler.newsSource.name} ===`);
    try {
      const articles = await crawler.getRSSContent(false, 5);
      console.log(`✓ Found ${articles.length} articles`);
      console.log(
        `✓ Images: ${articles.filter((a) => a.image).length}/${articles.length}`,
      );
    } catch (error) {
      console.error(`✗ Error:`, error);
    }
  }
}
```

### Test Image Extraction Only

```typescript
async function testImageExtraction() {
  const crawler = new DirectorioCubanoRSSCrawler();
  const parser = crawler.newsSource.parser;
  const feed = await parser.parseURL(crawler.newsSource.rssFeed);

  for (const item of feed.items.slice(0, 5)) {
    const imageUrl = crawler.tryGetMediaImage(item);
    console.log(`Article: ${item.title}`);
    console.log(`Image: ${imageUrl || "NO IMAGE"}\n`);
  }
}
```

## Related Files

- Main crawler code: `/Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed/src/app/cubanewsRSSCrawler.ts`
- Interfaces: `/Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed/src/app/interfaces/index.ts`
- Test file: `/Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed/test-rss.ts`
- Package scripts: `/Users/sergionava/github/cubanews/cubanewsjs/cubanews-feed/package.json`
