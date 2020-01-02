--- Eva token module
-- Provide API to add single token to profile
-- Tokens is basic item, like money, energy or items.
-- For adding group of tokens use eva.tokens
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local const = require("eva.const")
local smart = require("eva.libs.smart.smart")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.token")

local M = {}


local function update_tokens_offset()
	if not app.settings.tokens.memory_protect then
		return
	end

	local tokens = app.smart_tokens
	for _, token in pairs(tokens) do
		token:random_offset()
	end
end


local function on_change_token(delta, reason, token_id, amount)
	events.event(const.EVENT.TOKEN_CHANGE, {
		delta = delta,
		token_id = token_id,
		reason = reason,
		amount = amount
	})
end


local function create_token_in_save(token_id, token_data)
	if not token_data then
		token_data = proto.get(const.EVA.TOKEN)
		app[const.EVA.TOKENS].tokens[token_id] = token_data
	end

	local config = app.token_config.token_config[token_id] or {}
	config.name = token_id
	local smart_token = smart.new(config, token_data)

	if app.settings.tokens.memory_protect then
		smart_token:random_offset()
	else
		smart_token:reset_offset()
	end

	smart_token:on_change(on_change_token)
	return smart_token
end


local function get_token(token_id)
	local tokens = app.smart_tokens

	if not tokens[token_id] then
		tokens[token_id] = create_token_in_save(token_id)
	end

	return tokens[token_id]
end


--- Add tokens to save
-- @function eva.token.add
function M.add(token_id, amount, reason, visual_later)
	return get_token(token_id):add(amount, reason, visual_later)
end


--- Set tokens to save
-- @function eva.token.set
function M.set(token_id, amount, reason)
	return get_token(token_id):set(amount, reason)
end


--- Get current token amount from save
-- @function eva.token.get
function M.get(token_id, amount)
	return get_token(token_id):get()
end


--- Try to pay tokens from save
-- @function eva.token.pay
-- @tparam string token_id Token id
-- @tparam number amount Amount to pay
-- @tparam string reason The reason to pay
function M.pay(token_id, amount, reason)
	return get_token(token_id):pay(amount, reason)
end


--- Check is enough to pay token
-- @function eva.token.is_enough
function M.is_enough(token_id, amount)
	return get_token(token_id):check(amount)
end


--- Return is token is maximum
-- @function eva.token.is_max
function M.is_max(token_id)
	return get_token(token_id):is_max()
end


--- Return is tokens equals to 0
-- @function eva.token.is_empty
function M.is_empty(token_id)
	return get_token(token_id):is_empty()
end


--- Add to tokens infinity time usage
-- @function eva.token.add_infinity_time
function M.add_infinity_time(token_id, seconds)
	return get_token(token_id):add_infinity_time(seconds)
end


--- Return is token is infinity now
-- @function eva.token.is_infinity
function M.is_infinity(token_id)
	return get_token(token_id):is_infinity()
end


--- Get amount of seconds till end of infinity time
-- @function eva.token.get_infinity_seconds
function M.get_infinity_seconds(token_id)
	return get_token(token_id):get_infinity_seconds()
end


--- Reset visual debt of tokens
-- @function eva.token.sync_visual
function M.sync_visual(token_id)
	return get_token(token_id):sync_visual()
end


--- Add visual debt to token
-- @function eva.token.add_visual
function M.add_visual(token_id, amount)
	return get_token(token_id):add_visual(amount)
end


--- Get current visual debt of token
-- @function eva.token.get_visual
function M.get_visual(token_id)
	return get_token(token_id):get_visual()
end


--- Get current time to next restore point
-- @function eva.token.get_seconds_to_restore
function M.get_seconds_to_restore(token_id)
	return get_token(token_id):get_seconds_to_restore()
end


function M.before_eva_init()
	app.smart_tokens = {}
	app.token_config = {}
	app.token_groups = {}
	app.token_lots = {}
end


local function load_config(config_name, db_name)
	if db_name then
		app[config_name] = app.db[db_name]
		logger:debug("Load token config part", { name = config_name, db_name = db_name })
	end
end


function M.on_eva_init()
	local settings = app.settings.tokens
	load_config("token_config", settings.config_token_config)
	load_config("token_groups", settings.config_token_groups)
	load_config("token_lots", settings.config_lots)

	app[const.EVA.TOKENS] = proto.get(const.EVA.TOKENS)
	saver.add_save_part(const.EVA.TOKENS, app[const.EVA.TOKENS])

	smart.set_time_function(game.get_time)
	events.subscribe(const.EVENT.GAME_FOCUS, update_tokens_offset)
end


function M.after_eva_init()
	for token_id, data in pairs(app[const.EVA.TOKENS].tokens) do
		-- Link behavior and data
		app.smart_tokens[token_id] = create_token_in_save(token_id, data)
	end

	if app.token_config then
		for token_id, value in pairs(app.token_config.token_config) do
			if value.restore and not app.smart_tokens[token_id] then
				app.smart_tokens[token_id] = create_token_in_save(token_id)
			end
		end
	end
end


function M.on_eva_update(dt)
	local tokens = app.smart_tokens
	for _, token in pairs(tokens) do
		token:update()
	end
end


return M