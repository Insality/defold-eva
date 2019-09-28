--- Defold-Eva tokens module
-- @submodule eva

local log = require("eva.log")
local const = require("eva.const")
local smart = require("eva.libs.smart.smart")

local logger = log.get_logger("eva.tokens")

local M = {}


local function on_change_token(delta, reason, token_id, amount)
	M._eva.events.event(const.EVENT.TOKEN_CHANGE, { delta = delta, token_id = token_id, reason = reason, amount = amount })
end


local function create_token(token_id, token_data)
	if not token_data then
		token_data = M._eva.proto.get(const.EVA.TOKEN)
		M._eva.app[const.EVA.TOKENS].tokens[token_id] = token_data
	end

	local config = M._eva.app.token_config[token_id] or {}
	config.name = token_id
	local smart_token = smart.new(config, token_data)

	smart_token:on_change(on_change_token)
	return smart_token
end


local function get_token(token_id)
	local tokens = M._eva.app.smart_tokens

	if not tokens[token_id] then
		tokens[token_id] = create_token(token_id)
	end

	return tokens[token_id]
end


--- Add tokens
-- @function eva.tokens.add
function M.add(token_id, amount, reason)
	return get_token(token_id):add(amount, reason)
end


--- Set tokens
-- @function eva.tokens.set
function M.set(token_id, amount, reason)
	return get_token(token_id):set(amount, reason)
end


--- Get current token amount
-- @function eva.tokens.get
function M.get(token_id, amount)
	return get_token(token_id):get()
end


--- Try to pay tokens
-- @function eva.tokens.pay
function M.pay(token_id, amount, reason)
	return get_token(token_id):pay(amount, reason)
end


--- Check is enough to pay token
-- @function eva.tokens.is_enough
function M.is_enough(token_id, amount)
	return get_token(token_id):check(amount)
end


--- Return is token is maximum
-- @function eva.tokens.is_max
function M.is_max(token_id)
	return get_token(token_id):is_max()
end


--- Return is tokens equals to 0
-- @function eva.tokens.is_empty
function M.is_empty(token_id)
	return get_token(token_id):is_empty()
end


--- Add to tokens infinity time usage
-- @function eva.tokens.add_infinity_time
function M.add_infinity_time(token_id, seconds)
	return get_token(token_id):add_infinity_time(seconds)
end


--- Return is token is infinity now
-- @function eva.tokens.is_infinity
function M.is_infinity(token_id)
	return get_token(token_id):is_infinity()
end


--- Get amount of seconds till end of infinity time
-- @function eva.tokens.get_infinity_seconds
function M.get_infinity_seconds(token_id)
	return get_token(token_id):get_infinity_seconds()
end


--- Reset visual debt of tokens
-- @function eva.tokens.sync_visual
function M.sync_visual(token_id)
	return get_token(token_id):sync_visual()
end


--- Add visual debt to token
-- @function eva.tokens.add_visual
function M.add_visual(token_id, amount)
	return get_token(token_id):add_visual(amount)
end


--- Get current visual debt of token
-- @function eva.tokens.get_visual
function M.get_visual(token_id)
	return get_token(token_id):get_visual()
end


--- Get current time to next restore point
-- @function eva.tokens.get_seconds_to_restore
function M.get_seconds_to_restore(token_id)
	return get_token(token_id):get_seconds_to_restore()
end


function M.before_game_start()
	M._eva.app.smart_tokens = {}
	M._eva.app.token_config = {}

	local settings = M._eva.app.settings.tokens
	if settings.token_config and settings.token_config ~= "" then
		local filename = settings.token_config
		M._eva.app.token_config = M._eva.utils.load_json(filename)

		logger:debug("Load token config", {path = filename})
	end
end


function M.on_game_start()
	M._eva.app[const.EVA.TOKENS] = M._eva.proto.get(const.EVA.TOKENS)
	M._eva.saver.add_save_part(const.EVA.TOKENS, M._eva.app[const.EVA.TOKENS])

	smart.set_time_function(M._eva.game.get_time)
end


function M.after_game_start()
	for token_id, data in pairs(M._eva.app[const.EVA.TOKENS].tokens) do
		-- Link behavior and data
		M._eva.app.smart_tokens[token_id] = create_token(token_id, data)
	end
end


function M.on_game_update(dt)
	local tokens = M._eva.app.smart_tokens
	for id, token in pairs(tokens) do
		token:update()
	end
end


return M
