--- Defold-Eva proto module
-- Load proto file and give API to work with them
-- @submodule eva

local log = require("eva.log")
local protoc = require("pb.protoc")

local logger = log.get_logger("eva.proto")

local M = {}


--- Get empty template from proto type
-- @function eva.proto.get
-- @tparam string proto_type name of proto message e.g. 'eva.Token'
-- @treturn table empty table with default values from proto
function M.get(proto_type)
	return pb.decode(proto_type)
end


function M.encode(proto_type, data)
	return pb.encode(proto_type, data)
end


function M.decode(proto_type, data)
	return pb.decode(proto_type, data)
end


function M.before_game_start()
	local settings = M._eva.app.settings.proto
	local proto_paths = settings.proto_paths

	for _, path in ipairs(proto_paths) do
		logger:debug("Load protofile", { path = path })
		protoc:loadfile(path)
	end
end


return M
