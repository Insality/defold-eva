local luax = require("eva.luax")
local const = require("eva.const")
local log = require("eva.log")

local logger = log.get_logger("eva.iaps")

local M = {}


local function list_callback(self, products, error)
	if not error then
		-- Saving price info
		for k, v in pairs(products) do
			-- for kk, vv in pairs(sell_items) do
			-- 	if vv.iap_id == k then
			-- 		vv.real_cost = v.price
			-- 		vv.price_string = v.price_string
			-- 		vv.currency = v.currency_code
			-- 	end
			-- end
		end
	end

	for k, v in pairs(products) do
		pprint(k, v)
	end

	M._eva.events.event(const.EVENT.IAP_UPDATE)
end


local function consume(item_id, transaction)
	local item = {} -- sell_items[item_id]

	if not item then
		logger:error("No item with item_id", {item_id = item_id})
		print("[Error]: No item with ID", item_id)
		return
	end

	-- TODO: Consume here
	-- save.add_item(item.gives, item.amount, const.REASON.shop)

	if transaction then
		M._eva.events.event(const.EVENT.IAP_PURCHASE, {id = item_id, iap_id = item.iap_id, currency = item.currency})
	end
end


local function iap_listener(self, transaction, error)
	M.is_purchasing = false

	if not error then
		if luax.math.is(transaction.state, iap.TRANS_STATE_PURCHASED, iap.TRANS_STATE_RESTORED) then
			print("Iap valid, restored or purchased")

			local item = {} --get_item_by_ident(transaction.ident)
			consume(item, transaction)

			if not item.forever or M._eva.device.is_ios() then
				iap.finish(transaction)
			end
		end
	else
		if error.reason == iap.REASON_USER_CANCELED then
			logger:info("Iap canceled", transaction.ident)
			M._eva.events.event(const.EVENT.IAP_CANCEL, transaction and transaction.ident or "n/a")
		end
	end
end


function M.buy(id)

end


function M.init()
	if not iap then
		-- enable_all()
		return
	end

	iap.set_listener(iap_listener)
	iap.list(M.settings.product_list, list_callback)
end


function M.before_game_start(settings)
	M.settings = settings
end


function M.on_game_start()
	M._iaps_prefs = M._eva.proto.get("eva.Iaps")

	M._eva.saver.add_save_part("eva.Iaps", M._iaps_prefs)
end


return M
