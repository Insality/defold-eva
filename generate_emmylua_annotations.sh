#!/bin/sh
echo "return " > ~/code/lua/emmylua-from-ldoc-annotations/eva.dump
ldoc --filter pl.pretty.dump eva >> ~/code/lua/emmylua-from-ldoc-annotations/eva.dump
lua ~/code/lua/emmylua-from-ldoc-annotations/main.lua ~/code/lua/emmylua-from-ldoc-annotations/eva.dump > annotations.lua
