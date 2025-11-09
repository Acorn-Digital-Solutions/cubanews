# Copilot Instructions for Cubanews

## Project Overview

Cubanews is the portal of the independent Cuban press - think of it as the Google News of Cuba-related content. The app is available at https://cubanews.icu

The objective is to amplify the message of the Cuban free press, especially inside Cuba, with the hope that it may contribute to overturn the communist dictatorship and bring democratic change.

## Architecture

This is a multi-platform project consisting of:

1. **Cubanews Crawler**: Runs daily to browse news source websites and extract data
2. **Cubanews Feed**: Web app presenting a selection of the most outstanding news of the day
3. **Mobile Apps**: Native Android and iOS applications

## Tech Stack

### Web (cubanewsjs/)
- **Framework**: Next.js (latest) with React 18
- **Language**: TypeScript
- **Styling**: Tailwind CSS, Material-UI (MUI Joy)
- **Database**: PostgreSQL with Kysely ORM
- **Deployment**: Vercel
- **Additional Tools**:
  - Firebase for storage
  - Apify for web scraping
  - Node-llama-cpp for AI summaries
  - Nodemailer for email
  - Facebook Business SDK for social media integration

### Android (cubanews-android/)
- **Language**: Kotlin
- **UI Framework**: Jetpack Compose
- **Min SDK**: 30
- **Target SDK**: 36
- **Testing**: JUnit, Espresso, MockK
- **Build System**: Gradle with Kotlin DSL

### iOS (cubanews-ios/)
- **Language**: Swift
- **Framework**: Native iOS with Xcode

## Project Structure

```
cubanews/
├── cubanewsjs/               # JavaScript/TypeScript projects
│   ├── cubanews-feed/        # Main Next.js web application
│   ├── cubanews-crawler/     # Main crawler
│   ├── adncuba-crawler/      # Source-specific crawlers
│   ├── catorceYmedio-crawler/
│   ├── cibercuba-crawler/
│   ├── cubanet-crawler/
│   ├── ddc-crawler/
│   ├── eltoque-crawler/
│   └── periodico-cubano-crawler/
├── cubanews-android/         # Android app
├── cubanews-ios/            # iOS app
└── cuba_app_logos/          # Assets
```

## Development Guidelines

### Setup Requirements

**Important**: Create a `github` folder in your HOME directory as scripts depend on this structure.

### Web Development (cubanewsjs/cubanews-feed)

**Setup**:
1. Install Node.js dependencies: `npm install`
2. Install Docker Desktop (includes Docker Compose)
3. Start PostgreSQL: `cd database-setup; docker compose up`
4. Create database (first time only):
   - Open admin console at `localhost:8080`
   - Create database named `cubanews`
   - Execute `create_tables.sql` query

**Running Locally**:
- Development server: `npm run dev` (opens at http://localhost:3000)
- Build: `npm run build`
- Lint: `npm run lint`
- Local crawling: `npm run start:local:dev`
- AI Summary: `npm run start:aiSummary` (requires `npm run models:pull` first)
- Mail sender: `npm run start:mail:dev`
- Facebook posting: `npm run start:postToFB:dev`

**Code Structure**:
- Main page: `src/app/home/page.tsx`
- Hot reload enabled for development
- Uses TypeScript strict mode
- ES Modules (type: "module")

### Android Development

**Build**:
- Uses Gradle with Kotlin DSL
- Compose for UI
- Firebase for storage
- Navigation with Jetpack Compose

**Testing**:
- Unit tests with JUnit
- UI tests with Espresso
- Mocking with MockK

### iOS Development

- Native Swift app
- Xcode project structure

## Coding Standards

### TypeScript/JavaScript
- Use TypeScript for type safety
- Follow Next.js conventions and best practices
- Use functional components with hooks in React
- Prefer async/await over promises
- Keep components small and focused
- Use server-only code appropriately (import "server-only")

### Kotlin (Android)
- Follow Kotlin coding conventions
- Use Jetpack Compose for UI
- Target Java 11 compatibility
- Use Material 3 design system
- Write tests for new features

### General
- Write clear, self-documenting code
- Add comments for complex logic
- Keep functions small and single-purpose
- Use meaningful variable and function names
- Follow existing code style in each project

## Database

- PostgreSQL is the primary database
- Use Kysely for type-safe queries
- Vercel Postgres for production
- Local setup requires Docker

## Deployment

### Web App
- Deploy to Vercel using `vercel` CLI
- Environment variables managed through Vercel
- Automatic deployments on push

### Mobile Apps
- Android: Standard Android deployment process
- iOS: Standard iOS deployment process

## Testing

### Web
- Run linting: `npm run lint`
- Build to verify: `npm run build`

### Android
- Unit tests: `./gradlew test`
- Instrumented tests: `./gradlew connectedAndroidTest`

## Key Features to Maintain

1. **News Aggregation**: Multiple crawlers gather news from various Cuban press sources
2. **AI Summarization**: Uses local LLaMA models for content summarization
3. **Multi-platform**: Web, Android, and iOS apps
4. **Email Notifications**: Automated news digest sending
5. **Social Media Integration**: Facebook posting capabilities
6. **Firebase Storage**: Asset and media management

## Special Considerations

- The project serves an important mission: supporting Cuban independent press
- Code should be maintainable by contributors with varying skill levels
- Performance is important as users may have limited connectivity
- Security is critical - no hardcoded credentials or sensitive data
- Respect rate limits when crawling news sources
- Handle errors gracefully in crawlers (sources may be unavailable)

## Common Tasks

### Adding a New News Source
1. Create a new crawler in `cubanewsjs/[source-name]-crawler/`
2. Follow the pattern of existing crawlers
3. Add to the main crawler orchestration
4. Test thoroughly before deploying

### Updating Dependencies
- Web: Use `npm update` and test thoroughly
- Android: Update in `build.gradle.kts` files
- Always check for breaking changes

### Database Schema Changes
1. Update `create_tables.sql`
2. Test migration locally
3. Update Kysely types
4. Deploy carefully to production

## Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Jetpack Compose](https://developer.android.com/jetpack/compose)
- Main website: https://cubanews.icu
- About page: https://cubanews.icu/about
