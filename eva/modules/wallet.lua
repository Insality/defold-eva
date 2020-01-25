--- Eva wallet module
-- Wrap on token module with predefined container_id
-- @submodule eva

local const = require("eva.const")

local token = require("eva.modules.token")

local M = {}


--- Add tokens to save
-- @function eva.wallet.add
function M.add(token_id, amount, reason, visual_later)
	return token.add(const.WALLET_CONTAINER, token_id, amount, reason, visual_later)
end


--- Add multiply tokens
-- @function eva.wallet.add_many
function M.add_many(tokens, reason)
	return token.add_many(const.WALLET_CONTAINER, tokens, reason)
end


--- Add multiply tokens by token_group_id
-- @function eva.wallet.add_group
function M.add_group(token_group_id, reason)
	return token.add_group(const.WALLET_CONTAINER, token_group_id, reason)
end


--- Set tokens to save
-- @function eva.wallet.set
function M.set(token_id, amount, reason)
	return token.set(const.WALLET_CONTAINER, token_id, amount, reason)
end


--- Get current token amount from save
-- @function eva.wallet.get
function M.get(token_id, amount)
	return token.get(const.WALLET_CONTAINER, token_id, amount)
end


--- Try to pay tokens from save
-- @function eva.wallet.pay
-- @tparam string token_id Token id
-- @tparam number amount Amount to pay
-- @tparam string reason The reason to pay
function M.pay(token_id, amount, reason)
	return token.pay(const.WALLET_CONTAINER, token_id, amount, reason)
end


--- Pay multiply tokens
-- @function eva.wallet.pay_many
-- @tparam evadata.Tokens tokens Tokens data
-- @tparam string reason The reason to pay
function M.pay_many(tokens, reason)
	return token.pay_many(const.WALLET_CONTAINER, tokens, reason)
end

--- Pay multiply tokens by token_group_id
-- @function eva.wallet.pay_group
-- @tparam string token_group_id The token group id
-- @tparam string reason The reason to pay
function M.pay_group(token_group_id, reason)
	return token.pay_group(const.WALLET_CONTAINER, token_group_id, reason)
end


--- Check is enough to pay token
-- @function eva.wallet.is_enough
function M.is_enough(token_id, amount)
	return token.is_enough(const.WALLET_CONTAINER, token_id, amount)
end


--- Check multiply tokens
-- @function eva.wallet.is_enough_many
-- @tparam evadata.Tokens tokens list
function M.is_enough_many(tokens)
	return token.is_enough_many(const.WALLET_CONTAINER, tokens)
end


--- Check multiply tokens by token_group_id
-- @function eva.wallet.is_enough_group
-- @tparam string token_group_id the token group id
function M.is_enough_group(token_group_id)
	return token.is_enough_group(const.WALLET_CONTAINER, token_group_id)
end


--- Return is token is maximum
-- @function eva.wallet.is_max
function M.is_max(token_id)
	return token.is_max(const.WALLET_CONTAINER, token_id)
end


--- Return is tokens equals to 0
-- @function eva.wallet.is_empty
function M.is_empty(token_id)
	return token.is_empty(const.WALLET_CONTAINER, token_id)
end


--- Add to tokens infinity time usage
-- @function eva.wallet.add_infinity_time
function M.add_infinity_time(token_id, seconds)
	return token.add_infinity_time(const.WALLET_CONTAINER, token_id, seconds)
end


--- Return is token is infinity now
-- @function eva.wallet.is_infinity
function M.is_infinity(token_id)
	return token.is_infinity(const.WALLET_CONTAINER, token_id)
end


--- Get amount of seconds till end of infinity time
-- @function eva.wallet.get_infinity_seconds
function M.get_infinity_seconds(token_id)
	return token.get_infinity_seconds(const.WALLET_CONTAINER, token_id)
end


--- Reset visual debt of tokens
-- @function eva.wallet.sync_visual
function M.sync_visual(token_id)
	return token.sync_visual(const.WALLET_CONTAINER, token_id)
end


--- Add visual debt to token
-- @function eva.wallet.add_visual
function M.add_visual(token_id, amount)
	return token.add_visual(const.WALLET_CONTAINER, token_id, amount)
end


--- Get current visual debt of token
-- @function eva.wallet.get_visual
function M.get_visual(token_id)
	return token.get_visual(const.WALLET_CONTAINER, token_id)
end


--- Get current time to next restore point
-- @function eva.wallet.get_seconds_to_restore
function M.get_seconds_to_restore(token_id)
	return token.get_seconds_to_restore(const.WALLET_CONTAINER, token_id)
end


return M
