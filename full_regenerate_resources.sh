bash ./tools/tiled_export.sh
rm -rf ./hextest/generated
node ./tiled_generator/index.js ./resources/tiled/ ./hextest/generated/