#!/bin/bash

ldoc .

emmylua_generator_path=~/code/lua/emmylua-from-ldoc-annotations


echo "Update EmmyLua annotations from ldoc"
original_path=$(pwd)
bash $emmylua_generator_path/export.sh $original_path
mv $emmylua_generator_path/annotations.lua $original_path/annotations.lua


echo "Update annotations from protofiles"

~/code/lua/emmylua-protoc-annotations/export.sh \
	~/code/defold/defold-eva/eva/resources \
	~/code/defold/defold-eva/eva/resources/eva.proto \
	>> $original_path/annotations.lua


