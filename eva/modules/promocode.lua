--- Eva promocode module
-- Can apply tokens or other stuff by code
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local time_string = require("eva.libs.time_string")

local db = require("eva.modules.db")
local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")

local M = {}


local function get_config()
	return db.get("Promocodes").promocodes
end


--- Get list of all redeemed codes
-- @funtion eva.promocode.get_applied_codes
-- @treturn string[] List of applied codes
function M.get_applied_codes()
	return app[const.EVA.PROMOCODES].applied
end


--- Check if promocode is already applied
-- @function eva.promocode.is_applied
-- @tparam string code The promocode itself
-- @treturn bool True if code is already redeemed
function M.is_applied(code)
	return luax.table.contains(app[const.EVA.PROMOCODES].applied, code)
end


--- Try redeem the code and get rewards
-- @function eva.promocode.redeem_code
-- @tparam string code The promocode itself
-- @treturn bool Result of success
function M.redeem_code(code)
	if M.is_can_redeem(code) then
		wallet.add_many(get_config()[code].tokens)
		if app.promocode_settings.on_code_redeem then
			app.promocode_settings.on_code_redeem(code)
		end

		table.insert(app[const.EVA.PROMOCODES].applied, code)
		events.event(const.EVENT.CODE_REDEEM, { code = code })
		return true
	end

	return false
end


--- Check if promocode can be redeem
-- @function eva.promocode.is_can_redeem
-- @tparam string code The promocode itself
-- @treturn bool True of false
function M.is_can_redeem(code)
	local config = get_config()

	if not code or not config[code] then
		return false
	end

	local start_date = config[code].start_date
	local end_date = config[code].end_date

	local is_date_valid = true
	if start_date ~= luax.string.empty and end_date ~= luax.string.empty then
		local current_time = game.get_time()
		local start_time = time_string.parse_ISO(start_date)
		local end_time = time_string.parse_ISO(end_date)
		is_date_valid = (start_time <= current_time) and (current_time <= end_time)
	end

	local is_applied = M.is_applied(code)
	local is_custom_ok = true
	if app.promocode_settings.is_can_code_redeem then
		is_custom_ok = app.promocode_settings.is_can_code_redeem(code)
	end

	return is_date_valid and not is_applied and is_custom_ok
end


--- Set promocode settings.
-- Pass settings in eva.init function
-- @function eva.promocode.set_settings
function M.set_settings(promocode_settings)
	app.promocode_settings = promocode_settings
end



function M.on_eva_init()
	app.promocode_settings = {}
	app[const.EVA.PROMOCODES] = proto.get(const.EVA.PROMOCODES)
	saver.add_save_part(const.EVA.PROMOCODES, app[const.EVA.PROMOCODES])
end


return M
