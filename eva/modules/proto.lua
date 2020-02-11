--- Eva proto module
-- Load proto file and give API to work with them
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local protoc = require("pb.protoc")

local logger = log.get_logger("eva.proto")

local M = {}


local OPTIONAL = "optional"
local REPEATED = "repeated"
local MESSAGE = "message"
local VALUE = "value"
local MAP = "map"


local function update_with_default_messages(proto_type, data)
	for name in pb.fields(proto_type) do
		local _, _, type, _, label = pb.field(proto_type, name)
		local _, _, field_type = pb.type(type)

		if field_type == MESSAGE then
			-- Nest messages
			if label == OPTIONAL then
				if not data[name] then
					data[name] = M.get(type)
				else
					data[name] = M.decode(type, M.encode(type, data[name]))
				end
			end

			-- Repeated list
			if label == REPEATED then
				for k, v in pairs(data[name]) do
					data[name][k] = M.decode(type, M.encode(type, v))
				end
			end
		end

		-- Repeated map (key-value)
		-- In repeated map we should get value inside Entry
		if field_type == MAP then
			if label == REPEATED then
				for k, v in pairs(data[name]) do
					local _, _, repeated_type = pb.field(type, VALUE)
					data[name][k] = M.decode(repeated_type, M.encode(repeated_type, v))
				end
			end
		end
	end
end


--- Get empty template from proto type
-- @function eva.proto.get
-- @tparam string proto_type name of proto message e.g. 'eva.Token'
-- @treturn table empty table with default values from proto
function M.get(proto_type)
	return M.decode(proto_type)
end


--- Encode protobuf
-- @function eva.proto.encode
function M.encode(proto_type, data)
	return pb.encode(proto_type, data)
end


--- Decode protobuf
-- @function eva.proto.decode
function M.decode(proto_type, bytes)
	local settings = app.settings.proto
	local data = pb.decode(proto_type, bytes)

	-- Fill nested messages with default values
	-- Add default fields even in repeated and map fields
	if settings.default_nest_messages then
		update_with_default_messages(proto_type, data)
	end

	return data
end


function M.before_eva_init()
	local settings = app.settings.proto
	local proto_paths = settings.proto_paths

	protoc.include_imports = true
	for path, values in pairs(proto_paths) do
		protoc:addpath(path)
		for _, proto in ipairs(values) do
			logger:debug("Load protofile", { path = path .. "/" .. proto })
			protoc:loadfile(proto)
		end
	end
end


return M
