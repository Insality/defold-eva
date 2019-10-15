echo "Start full re-export..."
bash ./tools/tiled_export.sh
rm -rf ./hextest/generated
node ./tiled_generator/index.js ./resources/tiled/ ./hextest/generated/

rm ./resources/mapping.json
mv ./hextest/generated/mapping.json ./resources/mapping.json

echo "Done!"