local log = require("eva.log")
local smart = require("eva.libs.smart.smart")

local logger = log.get_logger("eva.tokens")

local M = {}
local token_config = {}
local tokens = {}


local function create_token(token_id)
	local empty_token = M._eva.proto.get("eva.Token")

	local smart_token = smart.new(token_config[token_id], empty_token)
	return smart_token
end


local function get_token(token_id)
	if not tokens[token_id] then
		tokens[token_id] = create_token(token_id)
	end

	return tokens[token_id]
end


function M.add(token_id, amount, reason)
	return get_token(token_id):add(amount, reason)
end


function M.set(token_id, amount, reason)
	return get_token(token_id):set(amount, reason)
end


function M.get(token_id, amount)
	return get_token(token_id):get()
end


function M.pay(token_id, amount, reason)
	return get_token(token_id):pay(amount, reason)
end


function M.is_enough(token_id, amount)
	return get_token(token_id):check(amount)
end


function M.is_max(token_id)
	return get_token(token_id):is_max()
end


function M.is_empty(token_id)
	return get_token(token_id):is_empty()
end


function M.add_infinity_time(token_id, seconds)
	return get_token(token_id):add_infinity_time(seconds)
end


function M.is_infinity(token_id)
	return get_token(token_id):is_infinity()
end


function M.get_infinity_seconds(token_id)
	return get_token(token_id):get_infinity_seconds()
end


function M.sync_visual(token_id)
	return get_token(token_id):sync_visual()
end


function M.add_visual(token_id, amount)
	return get_token(token_id):add_visual(amount)
end


function M.get_visual(token_id)
	return get_token(token_id):get_visual()
end


function M.get_seconds_to_restore(token_id)
	return get_token(token_id):get_seconds_to_restore()
end


function M.before_game_start(settings)
	if settings.token_config and settings.token_config ~= "" then
		local filename = settings.token_config
		token_config = M._eva.utils.load_json(filename)

		logger:debug("Load token config", {path = filename})
	end
end


function M.on_game_start()
	M._tokens_prefs = M._eva.proto.get("eva.Tokens")
	M._eva.saver.add_save_part("eva.Tokens", M._tokens_prefs)

	smart.set_time_function(M._eva.game.get_time)
end


function M.after_game_start()
	for token_id, data in pairs(M._tokens_prefs.tokens) do
		tokens[token_id] = smart.new(token_config[token_id], data)
	end
end


function M.on_game_update(dt)
	for id, token in pairs(tokens) do
		token:update()
	end
end


return M
