--- Eva invoices module
-- Can be used to add to user prizes with
-- delay or by event (game mail, from server, from pushes)
-- @submodule eva


local M = {}


--- Add invoice to game profile
-- If time is not provided, add invoice instantly
-- If time is provided, add invoice in this time
-- Invoice should be consumed to get reward
-- @function eva.invoices.add
-- @tparam evadata.Tokens tokens Tokens reward list
-- @tparam string category Category param of the invoice
-- @tparam number time Game time to add invoice
function M.add(tokens, category, time)

end


--- Return current list of invoices
function M.get_invoices()

end


--- Consume the invoice to the game profile
-- @function eva.invoices.consume
-- @tparam number invoice_id The id of invoice
function M.consume(invoice_id)

end


return M
