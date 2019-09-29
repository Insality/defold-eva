--- Defold-eva key-value storage
-- Using for simple key-value storage
-- @submodule eva

local luax = require("eva.luax")
local const = require("eva.const")
local log = require("eva.log")

local logger = log.get_logger("eva.storage")

local M = {}


function M.get(id)
	local storage = M._eva.app[const.EVA.STORAGE].storage
	local value = storage[id]

	return value.s_value or value.i_value or value.b_value
end


function M.set(id, value)
	local storage = M._eva.app[const.EVA.STORAGE].storage
	local v = M._eva.proto.get(const.EVA.STORAGE_VALUE)

	if type(value) == "string" then
		v.s_value = value
	end
	if type(value) == "number" then
		v.i_value = value
	end
	if type(value) == "boolean" then
		v.b_value = value
	end

	if luax.table.is_empty(v) then
		logger:error("Wrong args type in eva.storage", { id = id, value = value })
		return
	end

	storage[id] = v
end


function M.on_game_start()
	M._eva.app[const.EVA.STORAGE] = M._eva.proto.get(const.EVA.STORAGE)
	M._eva.saver.add_save_part(const.EVA.STORAGE, M._eva.app[const.EVA.STORAGE])
end


return M