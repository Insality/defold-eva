local settings = require("eva.settings.default")
local protoc = require("pb.protoc")

local log = require("eva.log")
local logger = log.get_logger()

local M = {}


function M.on_game_start()
	local proto_sources = settings.proto.proto_sources

	for path, name_array in pairs(proto_sources) do
		for index, name in ipairs(name_array) do
			print("Load file", path .. name)
			protoc:loadfile(path .. name .. ".proto")
		end
	end
end


function M.get(proto_type)
	return pb.decode(proto_type)
end


return M
