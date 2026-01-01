
echo "$(date) Refreshing feed Locally" > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/ddc-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/adncuba-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/catorceYmedio-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/cibercuba-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/cubanet-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/eltoque-crawler && npm run start > $HOME/cubanews-crawler.log 2>&1;
cd $HOME/github/cubanews/cubanewsjs/cubanews-feed && npm run start:local > $HOME/cubanews-crawler.log 2>&1;
npm run start:mail > $HOME/cubanews-crawler.log 2>&1;
npm run start:postToFB:playwright > $HOME/cubanews-crawler.log 2>&1;
echo "$(date) Completed Refreshing feed Locally" > ~/cubanews-crawler.log 2>&1;
