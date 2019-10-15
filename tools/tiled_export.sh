tiled="/Applications/Tiled.app/Contents/MacOS/Tiled"

$tiled --export-tileset ./hextest/tiled/maps/objects.tsx ./resources/tiled/resources.json
$tiled --export-tileset ./hextest/tiled/maps/decals.tsx ./resources/tiled/decals.json
$tiled --export-tileset ./hextest/tiled/maps/hexes.tsx ./resources/tiled/hexes.json

$tiled --export-map ./hextest/tiled/maps/test.tmx ./resources/tiled/hextest.json