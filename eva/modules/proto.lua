local log = require("eva.log")
local protoc = require("pb.protoc")

local logger = log.get_logger("eva.proto")

local M = {}


function M.before_game_start(settings)
	local proto_paths = settings.proto_paths

	for path, name_array in pairs(proto_paths) do
		for index, name in ipairs(name_array) do
			local filepath = path .. name .. ".proto"
			logger:debug("Load protofile", { path = filepath })
			protoc:loadfile(filepath)
		end
	end
end


function M.get(proto_type)
	return pb.decode(proto_type)
end


return M
