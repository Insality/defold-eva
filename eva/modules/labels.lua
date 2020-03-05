--- Eva labels module
-- Add labels to the player to separate players on groups
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")

local db = require("eva.modules.db")
local ads = require("eva.modules.ads")
local iaps = require("eva.modules.iaps")
local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")

local M = {}


local function get_labels_config()
	local config_name = app.settings.labels.config
	return db.get(config_name).labels
end


local spec_values_handlers = {
	["ltv"] = iaps.get_ltv,
	["maxpay"] = iaps.get_max_payment,
	["ads"] = ads.get_ads_watched,
	["days"] = game.get_days_played,
}

local function get_spec_key_value(key)
	return spec_values_handlers[key]()
end


local function check_spec_condition(cond)
	if not cond then
		return true
	end

	local result = true
	for i = 1, #cond do
		local data = cond[i]
		local key = data[1]
		local op = data[2]
		local value = data[3]
		local key_value = get_spec_key_value(key)

		result = result and luax.operators[op](key_value, value)
	end

	return result
end


local function check_token_condition(cond)
	if not cond then
		return true
	end

	local result = true
	for i = 1, #cond do
		local data = cond[i]
		local key = data[1]
		local op = data[2]
		local value = data[3]
		local key_value = wallet.get(key)

		result = result and luax.operators[op](key_value, value)
	end

	return result
end


local function check_conditions(label_data)
	local condition = true

	local spec = label_data.spec_cond
	condition = condition and check_spec_condition(spec)

	local token = label_data.token_cond
	condition = condition and check_token_condition(token)

	return condition
end


local function check_label(label_id, label_data)
	local is_need = check_conditions(label_data)
	local is_exist = M.is_exist(label_id)

	if is_exist and not is_need then
		luax.table.remove_item(app[const.EVA.LABELS].labels, label_id)
		events.event(const.EVENT.LABEL_REMOVE, { label_id = label_id })
	end

	if not is_exist and is_need then
		table.insert(app[const.EVA.LABELS].labels, label_id)
		events.event(const.EVENT.LABEL_ADD, { label_id = label_id })
	end

end


local function update_labels()
	local labels_data = get_labels_config()
	for id, data in pairs(labels_data) do
		check_label(id, data)
	end
end


function M.on_eva_init()
	app[const.EVA.LABELS] = proto.get(const.EVA.LABELS)
	saver.add_save_part(const.EVA.LABELS, app[const.EVA.LABELS])
end


function M.after_eva_init()
	update_labels()
end


--- Check label is exist in player profile
-- @function eva.labels.is_exist
-- @tparam string label The label id
-- @treturn bool True, if label in player profile
function M.is_exist(label)
	local labels = app[const.EVA.LABELS].labels
	return luax.table.contains(labels, label)
end


return M
