--- Eva IAPs module
-- Can process all in-apps in your application
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")
local fun = require("eva.libs.fun")

local db = require("eva.modules.db")
local game = require("eva.modules.game")
local saver = require("eva.modules.saver")
local proto = require("eva.modules.proto")
local token = require("eva.modules.token")
local device = require("eva.modules.device")
local events = require("eva.modules.events")
local wallet = require("eva.modules.wallet")

local logger = log.get_logger("eva.iaps")

local M = {}


local function get_iaps_config()
	local settings = app.settings.iaps
	local is_ios = device.is_ios()
	local config_name = is_ios and settings.config_ios or settings.config_android
	return db.get(config_name).iaps
end


local function load_config()
	app.iap_products = {}

	local iaps = get_iaps_config()
	for iap_id, info in pairs(iaps) do
		app.iap_products[iap_id] = {
			is_available = false,
			category = info.category,
			price = info.price,
			ident = info.ident,
			reward_id = info.token_group_id,
			price_string = info.price .. " $",
			currency_code = "USD",
			title = "",
			description = "",
		}
	end
end


local function get_id_by_ident(ident)
	for iap_id, value in pairs(app.iap_products) do
		if value.ident == ident then
			return iap_id
		end
	end

	return false
end


local function list_callback(self, products, error)
	if not error then
		local products_string = table.concat(luax.table.list(products), ", ")
		logger:info("Get product list", { products =  products_string })

		for k, v in pairs(products) do
			local iap_id = get_id_by_ident(k)
			local iap_info = app.iap_products[iap_id]

			iap_info.is_available = true
			iap_info.currency_code = v.currency_code
			iap_info.title = v.title
			iap_info.description = v.description
			iap_info.price_string = v.price_string
			iap_info.price = v.price
		end
	else
		logger:warn("IAP update products error", { error = error })
	end

	events.event(const.EVENT.IAP_UPDATE)
end


local function fake_transaction(iap_id, state)
	return {
		ident = iap_id,
		state = state or const.IAP.STATE.PURCHASED,
		date = game.get_current_time_string(),
		trans_ident = device.get_uuid(),
		is_fake = true,
	}
end


local function get_fake_products()
	local products = {}

	for iap_id, value in pairs(app.iap_products) do
		products[value.ident] = {
			currency_code = "USD",
			title = "Fake title",
			description = "Fake description",
			price_string = "$" .. value.price,
			price = value.price
		}
	end

	return products
end


local function save_iap(iap_id, transaction)
	local purchased = app[const.EVA.IAPS].purchased_iaps
	local iap_data = proto.get(const.EVA.IAP_INFO)

	iap_data.transaction_id = transaction.trans_ident
	iap_data.ident = transaction.ident
	iap_data.iap_id = iap_id
	iap_data.state = transaction.state
	iap_data.date = transaction.date

	table.insert(purchased, iap_data)
end


local function consume(iap_id, transaction)
	local item = M.get_iap(iap_id)

	if not item then
		logger:error("The iap_id is not exist", { iap_id = iap_id })
		return
	end

	if item.reward_id then
		wallet.add_group(item.reward_id, const.REASON.IAP)
	end

	save_iap(iap_id, transaction)

	if iap and (not item.forever or device.is_ios()) then
		iap.finish(transaction)
	end

	events.event(const.EVENT.IAP_PURCHASE, { iap_id = iap_id, ident = item.ident })
end


local function iap_listener(self, transaction, error)
	if not error then
		if luax.math.is(transaction.state, const.IAP.STATE.PURCHASED, const.IAP.STATE.RESTORED) then
			local iap_id = get_id_by_ident(transaction.ident)
			consume(iap_id, transaction)
		end
	else
		if error.reason == const.IAP.REASON.CANCELED then
			events.event(const.EVENT.IAP_CANCEL, transaction and transaction.ident or "n/a")
		else
			logger:warn("Error while IAP processing", transaction)
		end
	end
end


--- Buy the inapp
-- @function eva.iaps.buy
-- @tparam string iap_id In-game inapp ID from iaps settings
function M.buy(iap_id)
	local products = app.iap_products
	local item = products[iap_id]

	if not item then
		logger:error("The IAP is not exist", { iap_id = iap_id })
		return
	end

	if iap then
		logger:info("Start process IAP", { iap_id = iap_id })
		iap.buy(item.ident)
	else
		M.test_buy_with_fake_state(iap_id, const.IAP.STATE.PURCHASED)
	end

	return true
end


function M.test_buy_with_fake_state(iap_id, state, is_canceled)
	local products = app.iap_products
	local item = products[iap_id]

	if not item then
		logger:error("The IAP is not exist", { iap_id = iap_id })
		return
	end

	logger:info("No IAP module, fake free transaction", { iap_id = iap_id })
	local ident = products[iap_id].ident

	local iap_error = nil
	if is_canceled then
		iap_error = {
			reason = const.IAP.REASON.CANCELED
		}
	end

	iap_listener(nil, fake_transaction(ident, state), iap_error)

	return true
end


--- Get reward from iap_id
-- @function eva.iaps.get_reward
-- @tparam string iap_id the inapp id
function M.get_reward(iap_id)
	local iap_data = get_iaps_config()[iap_id]
	if not iap_data then
		logger:error("No iap with id", { iap_id = iap_id })
	end

	return token.get_token_group(iap_data.token_group_id)
end


--- Get iap info by iap_id
-- @function eva.iaps.get_iap
-- @tparam string iap_id the inapp id
function M.get_iap(iap_id)
	return app.iap_products[iap_id]
end


--- Get all iaps. Can be selected by category
-- @function eva.iaps.get_iaps
-- @tparam string category Category of iap
-- @treturn list of iap products
function M.get_iaps(category)
	if not category then
		return app.iap_products
	else
		return fun.filter(function(id, iap_data)
			return iap_data.category == category
		end, app.iap_products):tomap()
	end
end


--- Check is iap is available
-- @function eva.iaps.is_available
-- @tparam string iap_id the inapp id
-- @treturn bool Is available
function M.is_available(iap_id)
	local data = M.get_iap(iap_id)
	if not data then
		logger:warn("No iap with id to check available", { iap_id = iap_id })
		return false
	end

	return data.is_available
end


--- Get price from iap_id
-- @function eva.iaps.get_price
-- @tparam string iap_id the inapp id
-- @treturn number Price of iap
function M.get_price(iap_id)
	return app.iap_products[iap_id].price
end


--- Get price_string from iap_id
-- @function eva.iaps.get_price_string
-- @tparam string iap_id the inapp id
-- @treturn string The iap price string
function M.get_price_string(iap_id)
	return app.iap_products[iap_id].price_string
end


--- Refresh iap list.
-- It make request to stores to get new info
-- Throw EVENT.IAP_UPDATE at end
-- @function eva.iaps.refresh_iap_list
function M.refresh_iap_list()
	if not iap then
		logger:debug("No iap on current platform. Fake iap module")
		list_callback(nil, get_fake_products())
		return
	end

	iap.set_listener(iap_listener)
	iap.list(luax.table.list(app.iap_products, "ident"), list_callback)
end


--- Get total lifetime value (from iaps)
-- @function eva.iaps.get_ltv
-- @treturn number Player's LTV
function M.get_ltv()
	if not app[const.EVA.IAPS] then
		return 0
	end

	local ltv = 0
	local purchased = app[const.EVA.IAPS].purchased_iaps

	for i = 1, #purchased do
		local info = purchased[i]
		local price = M.get_price(info.iap_id) or 0
		ltv = ltv + price
	end

	return ltv
end


--- Get player max payment
-- @function eva.iaps.get_max_payment
-- @treturn number Max player payment
function M.get_max_payment()
	if not app[const.EVA.IAPS] then
		return 0
	end

	local max_pay = 0
	local purchased = app[const.EVA.IAPS].purchased_iaps

	for i = 1, #purchased do
		local info = purchased[i]
		local price = M.get_price(info.iap_id) or 0
		max_pay = math.max(max_pay, price)
	end

	return max_pay
end


function M.before_eva_init()
	app.iap_products = {}
end


function M.on_eva_init()
	app[const.EVA.IAPS] = proto.get(const.EVA.IAPS)
	saver.add_save_part(const.EVA.IAPS, app[const.EVA.IAPS])
end


function M.after_eva_init()
	load_config()
	M.refresh_iap_list()
end


return M
