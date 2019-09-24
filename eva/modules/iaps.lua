--- Defold-Eva IAPs module
-- Can process all in-apps in your application
-- @submodule eva

local luax = require("eva.luax")
local const = require("eva.const")
local log = require("eva.log")

local logger = log.get_logger("eva.iaps")

local M = {}

M.iap_products = {}


local function load_config(settings)
	M.iap_products = {}

	local is_ios = M._eva.device.is_ios()
	local config = is_ios and settings.config_ios or settings.config_android
	local data = M._eva.utils.load_json(config)

	for iap_id, info in pairs(data.iaps) do
		M.iap_products[iap_id] = {
			forever = info.foverer,
			is_available = false,
			price = info.price,
			ident = info.ident,
			price_string = info.price .. " $",
			currency_code = "USD",
			title = "",
			description = "",
		}
	end
end


local function get_id_by_ident(ident)
	for iap_id, v in pairs(M.iap_products) do
		if v.ident == ident then
			return iap_id
		end
	end

	return false
end


local function list_callback(self, products, error)
	if not error then
		local products_string = table.concat(luax.table.list(products), ", ")
		logger:info("Get product list", { products =  products_string})

		for k, v in pairs(products) do
			local iap_id = get_id_by_ident(k)
			local iap_info = M.iap_products[iap_id]

			iap_info.is_available = true
			iap_info.currency_code = v.currency_code
			iap_info.title = v.title
			iap_info.description = v.description
			iap_info.price_string = v.price_string
			iap_info.price = v.price
		end
	else
		logger:warn("IAP udpate products error", { error = error })
	end

	M._eva.events.event(const.EVENT.IAP_UPDATE)
end


local function fake_transaction(iap_id)
	return {
		ident = iap_id,
		state = "success (sandbox)",
		date = M._eva.game.get_current_time_string(),
		trans_ident = M._eva.game.get_uuid(),
		is_fake = true,
	}
end


local function save_iap(iap_id, transaction)
	local purchased = M._iaps_prefs.purchased_iaps
	local iap_data = M._eva.proto.get(const.EVA.IAP_INFO)

	iap_data.transaction_id = transaction.trans_ident
	iap_data.ident = transaction.ident
	iap_data.iap_id = iap_id
	iap_data.state = transaction.state
	iap_data.date = transaction.date

	table.insert(purchased, iap_data)
end


local function consume(iap_id, transaction)
	local item = M.iap_products[iap_id]

	if not item then
		logger:error("The iap_id is not exist", {iap_id = iap_id})
		return
	end

	save_iap(iap_id, transaction)

	if iap and (not item.forever or M._eva.device.is_ios()) then
		iap.finish(transaction)
	end

	M._eva.events.event(const.EVENT.IAP_PURCHASE, {iap_id = iap_id, ident = item.ident})
end


local function iap_listener(self, transaction, error)
	if not error then
		if luax.math.is(transaction.state, iap.TRANS_STATE_PURCHASED, iap.TRANS_STATE_RESTORED) then
			local iap_id = get_id_by_ident(transaction.ident)
			consume(iap_id, transaction)
		end
	else
		if error.reason == iap.REASON_USER_CANCELED then
			logger:info("Iap canceled", transaction)
			M._eva.events.event(const.EVENT.IAP_CANCEL, transaction and transaction.ident or "n/a")
		else
			logger:warn("Error while IAP processing", transaction)
		end
	end
end


--- Buy the inapp
-- @function eva.iaps.buy
-- @tparam string iap_id In-game inapp ID from iaps settings
function M.buy(iap_id)
	local item = M.iap_products[iap_id]

	if not item then
		logger:error("The IAP is not exist", { iap_id = iap_id })
		return
	end

	if iap then
		logger:info("Start process IAP", { iap_id = iap_id })
		iap.buy(item.ident)
	else
		logger:info("No IAP module, fake free transaction", { iap_id = iap_id })
		local ident = M.iap_products[iap_id].ident
		consume(iap_id, fake_transaction(ident))
	end
end


function M.before_game_start(settings)
	M.settings = settings
	load_config(settings)
end


function M.on_game_start()
	M._iaps_prefs = M._eva.proto.get(const.EVA.IAPS)
	M._eva.saver.add_save_part(const.EVA.IAPS, M._iaps_prefs)
end


function M.after_game_start()
	if not iap then
		logger:debug("No iap on current platform")
		return
	end

	iap.set_listener(iap_listener)
	iap.list(luax.table.list(M.iap_products, "ident"), list_callback)
end


return M
