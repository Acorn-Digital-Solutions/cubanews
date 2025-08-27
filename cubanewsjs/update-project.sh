echo "Pulling latest from main";
git pull;

echo "Building cubanews crawler";
cd cubanews-crawler; npm i; npm run build;

echo "Updating adncuba-crawler";
cd ../adncuba-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating caterceYmedio-crawler";
cd ../catorceYmedio-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating cibercuba-crawler";
cd ../cibercuba-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating ddc-crawler";
cd ../ddc-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating eltoque-crawler";
cd ../eltoque-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating cubanet-crawler"
cd ../cubanet-crawler; npm i; npm link ../cubanews-crawler;

echo "Update diario-cubano-crawler"
cd ../diario-cubano-crawler; npm i; npm link ../cubanews-crawler;

echo "Updating cubanews-feed"
cd ../cubanews-feed; npm i;