--- Eva key-value storage
-- Using for simple key-value local storage
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local log = require("eva.log")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local logger = log.get_logger("eva.storage")

local M = {}


--- Get the value from the storage.
-- @function eva.storage.get
-- @tparam string id The record id
function M.get(id)
	local storage = app[const.EVA.STORAGE].storage
	local value = storage[id]

	return value.s_value or value.i_value or value.b_value
end

--- Set the value to eva storage
-- @function eva.storage.set
-- @tparam string id The record id
-- @tparam string|number|bool value Value
function M.set(id, value)
	local storage = app[const.EVA.STORAGE].storage
	local v = proto.get(const.EVA.STORAGE_VALUE)

	if type(value) == const.TYPE.STRING then
		v.s_value = value
	end
	if type(value) == const.TYPE.NUMBER then
		v.i_value = value
	end
	if type(value) == const.TYPE.BOOLEAN then
		v.b_value = value
	end

	if luax.table.is_empty(v) then
		logger:error("Wrong args type in eva.storage", { id = id, value = value })
		return
	end

	storage[id] = v
end


function M.on_eva_init()
	app[const.EVA.STORAGE] = proto.get(const.EVA.STORAGE)
	saver.add_save_part(const.EVA.STORAGE, app[const.EVA.STORAGE])
end


return M