# cubanews-feed

The project containing the UI of cubanews. A small web app that gets scrapped news and displays them in a list.

## Setup

1. Install node dependencies: `npm install`
2. Install docker including docker compose. Recommended install Docker Desktop as it will include both.
3. Start the local instance of Postgres `cd database-setup; docker compose up`
   This will start a container with postgress and an admin console.
4. This step is required only once to create the database.
   - Open the admin console at `localhost:8080`
   - Create a new database called `cubanews`
   - Execute the query in `create_tables.sql`

## Run cubanews-feed locally

1. Make sure to complete the Setup steps above
2. Run the development server: `npm run dev`

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `src/app/home/page.tsx`. The page auto-updates as you edit the file.

## Populate the database

This will run the a full crawling and updating of the feed in the local database.

`cd cubanews-crawler; ./run-dev.sh`

## Learn More about NextJS

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## Deploy on Vercel

Install vercel command line tool and use it to deploy.

```bash
npm i -g vercel;
cd cubanews-feed;
vercel
```

Run `vercel --help` for more information

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.

## How to run the AI Summary script

1. Pull the model by running `npm run models:pull`. This is needed only once.
2. `npm run start:aiSummary`
