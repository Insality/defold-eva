--- Eva proto module
-- Load proto file and give API to work with them
-- @submodule eva


local app = require("eva.app")
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


--- Encode protobuf
-- @function eva.proto.decode
function M.encode(proto_type, data)
	return pb.encode(proto_type, data)
end


--- Decode protobuf
-- @function eva.proto.decode
function M.decode(proto_type, data)
	return pb.decode(proto_type, data)
end


function M.before_eva_init()
	local settings = app.settings.proto
	local proto_paths = settings.proto_paths

	protoc.include_imports = true
	for path, values in pairs(proto_paths) do
		protoc:addpath(path)
		for _, proto in ipairs(values) do
			logger:debug("Load protofile", { path = path .. proto })
			protoc:loadfile(proto)
		end
	end
end


return M
