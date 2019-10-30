--- Eva invoices module
-- Can be used to add to user prizes with
-- delay or by event (game mail, from server, from pushes)
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")
local fun = require("eva.libs.fun")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local tokens = require("eva.modules.tokens")
local events = require("eva.modules.events")
local device = require("eva.modules.device")

local logger = log.get_logger("eva.invoices")

local M = {}


local function remove_invoice(id)
	app[const.EVA.INVOICES].invoices[id] = nil
end


local function expire_invoice(id)
	local invoice = M.get_invoice(id)

	if not invoice then
		logger:warn("No invoice to expire", { id = id })
		return
	end

	remove_invoice(id)
	events.event(const.EVENT.INVOICE_EXPIRE, { id = id, category = invoice.category })
end


local function update_expired_invoices()
	local invoices = app[const.EVA.INVOICES].invoices
	local current_time = game.get_time()

	for id, invoice in pairs(invoices) do
		if invoice.life_time > 0 then
			local end_time = invoice.start_time + invoice.life_time

			if end_time < current_time then
				expire_invoice(id)
			end
		end
	end
end


--- Add invoice to game profile
-- If time is not provided, add invoice instantly
-- If time is provided, add invoice in this time
-- Invoice should be consumed to get reward
-- @function eva.invoices.add
-- @tparam string category Category param of the invoice
-- @tparam evadata.Tokens reward Tokens reward list
-- @tparam number time Game time to add invoice
function M.add(category, reward, start_time, life_time, title, text)
	local invoices = app[const.EVA.INVOICES].invoices
	local current_time = game.get_time()
	start_time = start_time or current_time

	local invoice = proto.get(const.EVA.INVOICE_INFO)
	invoice.category = category
	invoice.start_time = start_time
	invoice.life_time = life_time or 0
	invoice.title = title or luax.string.empty
	invoice.text = text or luax.string.empty
	invoice.reward = reward

	local id = device.get_uuid(luax.table.list(invoices))
	invoices[id] = invoice

	events.event(const.EVENT.INVOICE_ADD, {
		category = category,
		start_time = start_time,
		id = id
	})

	return id
end


--- Return current list of invoices
-- @function eva.invoices.get_invoices
function M.get_invoices(category)
	if not category then
		return app[const.EVA.INVOICES].invoices
	else
		return fun.filter(function(id, invoice)
			return invoice.category == category
		end, app[const.EVA.INVOICES].invoices):tomap()
	end
end


function M.get_invoice(id)
	return app[const.EVA.INVOICES].invoices[id]
end


function M.can_consume(id)
	local invoice = M.get_invoice(id)

	if not invoice then
		return false
	end

	return game.get_time() >= invoice.start_time
end

--- Consume the invoice to the game profile
-- @function eva.invoices.consume
-- @tparam number invoice_id The id of invoice
function M.consume(id)
	local invoices = app[const.EVA.INVOICES].invoices
	local invoice = invoices[id]
	local current_time = game.get_time()

	if not invoice then
		logger:warn("No invoice to consume", { id = id })
		return
	end

	if invoice.start_time > current_time then
		logger:warn("Trying to consume not ready invoice", { id = id })
		return
	end

	local reward = invoice.reward
	if reward then
		tokens.add(reward)
	end

	remove_invoice(id)
	events.event(const.EVENT.INVOICE_CONSUME, { category = invoice.category, id = id })
end


function M.on_eva_init()
	app[const.EVA.INVOICES] = proto.get(const.EVA.INVOICES)
	saver.add_save_part(const.EVA.INVOICES, app[const.EVA.INVOICES])

	update_expired_invoices()
end


function M.on_eva_second()
	update_expired_invoices()
end


return M
