tiled="/Applications/Tiled.app/Contents/MacOS/Tiled"

mkdir -p ./resources/tilesets/
$tiled --export-tileset ./hextest/tiled/tilesets/basic_resources.tsx ./resources/tilesets/basic_resources.json
$tiled --export-tileset ./hextest/tiled/tilesets/basic_decals.tsx ./resources/tilesets/basic_decals.json
$tiled --export-tileset ./hextest/tiled/tilesets/basic_hexes.tsx ./resources/tilesets/basic_hexes.json
$tiled --export-tileset ./hextest/tiled/tilesets/basic_iso_tileset.tsx ./resources/tilesets/basic_iso_tileset.json
$tiled --export-tileset ./hextest/tiled/tilesets/basic_grid.tsx ./resources/tilesets/basic_grid.json

$tiled --export-map ./hextest/tiled/maps/hextest.tmx ./resources/maps/hextest.json
$tiled --export-map ./hextest/tiled/maps/isotest.tmx ./resources/maps/isotest.json
$tiled --export-map ./hextest/tiled/maps/gridtest.tmx ./resources/maps/gridtest.json
