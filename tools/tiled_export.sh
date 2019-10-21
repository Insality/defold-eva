tiled="/Applications/Tiled.app/Contents/MacOS/Tiled"

$tiled --export-tileset ./hextest/tiled/maps/resources.tsx ./resources/tiled/resources.json
$tiled --export-tileset ./hextest/tiled/maps/decals.tsx ./resources/tiled/decals.json
$tiled --export-tileset ./hextest/tiled/maps/hexes.tsx ./resources/tiled/hexes.json
$tiled --export-tileset ./hextest/tiled/maps/iso_tileset.tsx ./resources/tiled/iso_tileset.json

$tiled --export-map ./hextest/tiled/maps/hextest.tmx ./resources/tiled/hextest.json
$tiled --export-map ./hextest/tiled/maps/isotest.tmx ./resources/tiled/isotest.json