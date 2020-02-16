echo "Start full re-export..."
bash ./tools/tiled_export.sh
rm -rf ./hextest/generated
node ~/code/js/defold-tiled-generator/index.js ./resources/tilesets/ ./resources/maps/ ./hextest/generated/

rm ./resources/mapping.json
mv ./hextest/generated/mapping.json ./resources/mapping.json

echo "Done!"