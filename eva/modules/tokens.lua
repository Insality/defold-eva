--- Eva tokens module
-- Provide API to profile tokens groups and arrays
-- @submodule eva


local log = require("eva.log")
local app = require("eva.app")
local const = require("eva.const")

local token = require("eva.modules.token")
local proto = require("eva.modules.proto")

local logger = log.get_logger("eva.group")

local M = {}


--- Return token group by id.
-- It pickup data from DB
-- @function eva.tokens.get_token_group
-- @tparam string token_group_id the token group id
-- @treturn evadata.Tokens the token list
function M.get_token_group(token_group_id)
	local group = app.token_groups.token_groups[token_group_id]

	if not group then
		logger:error("No token group with id", { group_id = token_group_id })
	end

	return group
end


--- Return evadata.Tokens tokens format
-- @function eva.tokens.get_tokens
-- @tparam table tokens Map with token_id = amount
function M.get_tokens(tokens)
	local data = proto.get(const.EVA.TOKENS_DATA)

	for token_id, amount in pairs(tokens) do
		table.insert(data.tokens, { token_id = token_id, amount = amount })
	end

	return data
end


--- Return lot reward by lot_id.
-- It pickup data from DB
-- @function eva.tokens.get_lot_reward
-- @tparam string lot_id the token lot id
-- @treturn evadata.Tokens the token list
function M.get_lot_reward(lot_id)
	local lot = app.token_lots.token_lots[lot_id]

	if not lot then
		logger:error("No token lot with id", { lot_id = lot_id })
	end

	return M.get_token_group(lot.reward)
end


--- Return lot price by lot_id.
-- It pickup data from DB
-- @function eva.tokens.get_lot_price
-- @tparam string lot_id the token lot id
-- @treturn evadata.Tokens the token list
function M.get_lot_price(lot_id)
	local lot = app.token_lots.token_lots[lot_id]

	if not lot then
		logger:error("No token lot with id", { lot_id = lot_id })
	end

	return M.get_token_group(lot.price)
end


--- Add multiply tokens
-- @function eva.tokens.add
function M.add(tokens, reason)
	if not tokens or #tokens.tokens == 0 then
		return
	end

	for index, value in ipairs(tokens.tokens) do
		token.add(value.token_id, value.amount, reason)
	end
end


--- Add multiply tokens by token_group_id
-- @function eva.tokens.add_group
function M.add_group(token_group_id, reason)
	local tokens = M.get_token_group(token_group_id)
	M.add(tokens)
end


--- Pay multiply tokens
-- @function eva.tokens.pay
-- @tparam evadata.Tokens tokens Tokens data
-- @tparam string reason The reason to pay
function M.pay(tokens, reason)
	for index, value in ipairs(tokens.tokens) do
		token.pay(value.token_id, value.amount, reason)
	end
end

--- Pay multiply tokens by token_group_id
-- @function eva.tokens.pay_group
-- @tparam string token_group_id The token group id
-- @tparam string reason The reason to pay
function M.pay_group(token_group_id, reason)
	local tokens = M.get_token_group(token_group_id)
	M.pay(tokens, reason)
end


--- Check multiply tokens
-- @function eva.tokens.is_enough
-- @tparam evadata.Tokens tokens list
function M.is_enough(tokens)
	local is_enough = true

	for index, value in ipairs(tokens.tokens) do
		is_enough = is_enough and token.is_enough(value.token_id, value.amount)
	end

	return is_enough
end


--- Check multiply tokens by token_group_id
-- @function eva.tokens.is_enough_group
-- @tparam string token_group_id the token group id
function M.is_enough_group(token_group_id)
	local tokens = M.get_token_group(token_group_id)
	return M.is_enough(tokens)
end


return M
