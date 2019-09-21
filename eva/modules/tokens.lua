local log = require("eva.log")
local settings = require("eva.settings.default")
local smart = require("eva.libs.smart.smart")

local logger = log.get_logger("eva.tokens")

local M = {}
local config = {}



local function create_token(token_id, amount)
	local empty_token = M._eva.proto.get("eva.Token")
	empty_token.amount = amount

	return empty_token
end


function M.add(token_id, amount)
	local tokens = M._tokens_prefs.tokens
	if not tokens[token_id] then
		tokens[token_id] = create_token(token_id, amount)
	end

	local token = tokens[token_id]
	token.amount = token.amount + amount
end


function M.pay(token_id, amount)
	M.add(token_id, -amount)
end


function M.is_enough(token_id, amount)

end


function M.before_game_start()
	config = {}
	if settings.tokens.token_config then
		local filename = settings.tokens.token_config
		config = cjson.decode(sys.load_resource(filename))
		logger:debug("Load token config", {path = filename})
	end
end


function M.on_game_start()
	M._tokens_prefs = M._eva.proto.get("eva.Tokens")

	M._eva.saver.add_save_part("eva.Tokens", M._tokens_prefs)
end


return M
