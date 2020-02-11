--- Eva token module
-- Provide API to work with tokens in special container
-- Tokens is basic item, like money, energy or items.
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")
local smart = require("eva.libs.smart.smart")

local db = require("eva.modules.db")
local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")
local events = require("eva.modules.events")

local logger = log.get_logger("eva.token")

local M = {}


local function get_token_lot_config(lot_id)
	local config_name = app.settings.tokens.config_lots
	return db.get(config_name).token_lots[lot_id]
end


local function get_token_group_config(group_id)
	local config_name = app.settings.tokens.config_token_groups
	return db.get(config_name).token_groups[group_id]
end


local function get_token_config()
	local config_name = app.settings.tokens.config_token_config
	return db.get(config_name).token_config
end


local function get_data_containers()
	return app[const.EVA.CONTAINERS].containers
end


local function get_container(container_id)
	return app.smart_containers[container_id]
end


local function update_tokens_offset()
	if not app.settings.tokens.memory_protect then
		return
	end

	local containers = app.smart_containers
	for _, container in pairs(containers) do
		for _, token in pairs(container) do
			token:random_offset()
		end
	end
end


local function on_change_token(token, delta, reason)
	events.event(const.EVENT.TOKEN_CHANGE, {
		delta = delta,
		token_id = token:get_token_id(),
		reason = reason,
		amount = token:get()
	})
end


local function get_config_for_token(container_id, token_id)
	local config = get_token_config()[token_id] or {}
	config.name = token_id

	return config
end


local function create_token_in_save(container_id, token_id, token_data)
	if not token_data then
		local container_data = get_data_containers()[container_id]
		token_data = proto.get(const.EVA.TOKEN)
		container_data.tokens[token_id] = token_data
	end

	local config = get_config_for_token(container_id, token_id)
	local smart_token = smart.new(config, token_data)

	if app.settings.tokens.memory_protect then
		smart_token:random_offset()
	else
		smart_token:reset_offset()
	end

	smart_token:on_change(on_change_token)
	return smart_token
end


local function get_token(container_id, token_id)
	assert(container_id, "You should provide container_id")
	assert(token_id, "You should provide token_id")

	local container = get_container(container_id)
	if not container then
		logger:error("No container with id", { container_id = container_id, token_id = token_id })
		return
	end

	if not container[token_id] then
		container[token_id] = create_token_in_save(container_id, token_id)
	end

	return container[token_id]
end


--- Check if token container exist
-- @function eva.token.is_exist_container
-- @tparam string container_id Container id
-- @treturn bool Container exist state
function M.is_exist_container(container_id)
	return luax.toboolean(get_container(container_id))
end


--- Create new token container
-- @function eva.token.create_container
-- @tparam string container_id Container id
-- @tparam string container_type Container type to match from token config
function M.create_container(container_id, container_type)
	if M.is_exist_container(container_id) then
		logger:warn("Container is already exist", { container_id = container_id })
		return
	end

	local data_containers = get_data_containers()

	data_containers[container_id] = proto.get(const.EVA.CONTAINER)
	data_containers[container_id].type = container_type
	app.smart_containers[container_id] = {}

	logger:debug("Create token container", { container_id = container_id, container_type = container_type })
end


--- Delete token container
-- @function eva.token.delete_container
-- @tparam string container_id Container id
function M.delete_container(container_id)
	local data_containers = get_data_containers()

	data_containers[container_id] = nil
	app.smart_containers[container_id] = nil
end


--- Clear all tokens from container
-- @function eva.token.clear_container
-- @tparam string container_id Container id
function M.clear_container(container_id)
	if not M.is_exist_container(container_id) then
		logger:warn("Cant clear non existing container", { container_id = container_id })
		return
	end

	local container = get_container(container_id)

	container.tokens = {}
	app.smart_containers[container_id] = {}
end


function M.set_restore_config(container_id, token_id, config)
	local restore_config = get_data_containers()[container_id].restore_config

	local new_config = proto.get(const.EVA.TOKEN_RESTORE_CONFIG)
	new_config.is_enabled = true
	new_config.last_restore_time = game.get_time()
	new_config.timer = config.timer
	new_config.value = config.value or new_config.value
	new_config.max = config.max or new_config.max

	restore_config[token_id] = new_config
end


function M.get_restore_config(container_id, token_id)
	return get_data_containers()[container_id].restore_config[token_id]
end


function M.set_pause_restore_config(container_id, token_id, is_pause)
	local config = M.get_restore_config(container_id, token_id)
	config.is_enabled = not is_pause
end


function M.remove_restore_config(container_id, token_id)
	local restore_config = get_data_containers()[container_id].restore_config
	assert(restore_config[token_id], "No restore config to delete it")
	restore_config[token_id] = nil
end


--- Return evadata.Tokens tokens format. Used in *_tokens methods
-- @function eva.token.get_tokens
-- @tparam table tokens Map with token_id = amount
function M.get_tokens(tokens)
	local data = proto.get(const.EVA.TOKENS_DATA)

	for token_id, amount in pairs(tokens) do
		table.insert(data.tokens, { token_id = token_id, amount = amount })
	end

	return data
end


--- Return token group by id.
-- It pickup data from DB
-- @function eva.token.get_token_group
-- @tparam string token_group_id the token group id
-- @treturn evadata.Tokens the token list
function M.get_token_group(token_group_id)
	local group = get_token_group_config(token_group_id)

	if not group then
		logger:error("No token group with id", { group_id = token_group_id })
	end

	return group
end


--- Return lot reward by lot_id.
-- It pickup data from DB
-- @function eva.token.get_lot_reward
-- @tparam string lot_id the token lot id
-- @treturn evadata.Tokens the token list
function M.get_lot_reward(lot_id)
	local lot = get_token_lot_config(lot_id)

	if not lot then
		logger:error("No token lot with id", { lot_id = lot_id })
	end

	return M.get_token_group(lot.reward)
end


--- Return lot price by lot_id.
-- It pickup data from DB
-- @function eva.token.get_lot_price
-- @tparam string lot_id the token lot id
-- @treturn evadata.Tokens the token list
function M.get_lot_price(lot_id)
	local lot = get_token_lot_config(lot_id)

	if not lot then
		logger:error("No token lot with id", { lot_id = lot_id })
	end

	return M.get_token_group(lot.price)
end


--- Add tokens to save
-- @function eva.token.add
function M.add(container_id, token_id, amount, reason, visual_later)
	return get_token(container_id, token_id):add(amount, reason, visual_later)
end


--- Add multiply tokens
-- @function eva.token.add_many
function M.add_many(container_id, tokens, reason)
	if not tokens or #tokens.tokens == 0 then
		return
	end

	for index, value in ipairs(tokens.tokens) do
		M.add(container_id, value.token_id, value.amount, reason)
	end
end


--- Add multiply tokens by token_group_id
-- @function eva.token.add_group
function M.add_group(container_id, token_group_id, reason)
	local tokens = M.get_token_group(token_group_id)
	M.add_many(container_id, tokens)
end


--- Set tokens to save
-- @function eva.token.set
function M.set(container_id, token_id, amount, reason)
	return get_token(container_id, token_id):set(amount, reason)
end


--- Get current token amount from save
-- @function eva.token.get
function M.get(container_id, token_id, amount)
	return get_token(container_id, token_id):get()
end


--- Get all tokens from container
-- @function eva.token.get_many
-- @tparam string container_id Container id
-- @treturn evadata.Tokens Tokens from container
function M.get_many(container_id)
	local tokens = {}

	local container = get_container(container_id)
	for id, token in pairs(container) do
		tokens[id] = token:get()
	end

	return M.get_tokens(tokens)
end


--- Try to pay tokens from save
-- @function eva.token.pay
-- @tparam string token_id Token id
-- @tparam number amount Amount to pay
-- @tparam string reason The reason to pay
function M.pay(container_id, token_id, amount, reason)
	if M.is_infinity(container_id, token_id) then
		return true
	end

	return get_token(container_id, token_id):pay(amount, reason)
end


--- Pay multiply tokens
-- @function eva.token.pay_many
-- @tparam evadata.Tokens tokens Tokens data
-- @tparam string reason The reason to pay
function M.pay_many(container_id, tokens, reason)
	for index, value in ipairs(tokens.tokens) do
		M.pay(container_id, value.token_id, value.amount, reason)
	end
end

--- Pay multiply tokens by token_group_id
-- @function eva.token.pay_group
-- @tparam string token_group_id The token group id
-- @tparam string reason The reason to pay
function M.pay_group(container_id, token_group_id, reason)
	local tokens = M.get_token_group(token_group_id)
	M.pay_many(container_id, tokens, reason)
end


--- Check is enough to pay token
-- @function eva.token.is_enough
function M.is_enough(container_id, token_id, amount)
	if M.is_infinity(container_id, token_id) then
		return true
	end

	return get_token(container_id, token_id):check(amount)
end


--- Check multiply tokens
-- @function eva.token.is_enough_many
-- @tparam evadata.Tokens tokens list
function M.is_enough_many(container_id, tokens)
	local is_enough = true

	for index, value in ipairs(tokens.tokens) do
		is_enough = is_enough and M.is_enough(container_id, value.token_id, value.amount)
	end

	return is_enough
end


--- Check multiply tokens by token_group_id
-- @function eva.token.is_enough_group
-- @tparam string token_group_id the token group id
function M.is_enough_group(container_id, token_group_id)
	local tokens = M.get_token_group(token_group_id)
	return M.is_enough_many(container_id, tokens)
end


--- Return is token is maximum
-- @function eva.token.is_max
function M.is_max(container_id, token_id)
	return get_token(container_id, token_id):is_max()
end


--- Return is tokens equals to 0
-- @function eva.token.is_empty
function M.is_empty(container_id, token_id)
	return get_token(container_id, token_id):is_empty()
end


--- Add to tokens infinity time usage
-- @function eva.token.add_infinity_time
function M.add_infinity_time(container_id, token_id, seconds)
	local timers = get_data_containers()[container_id].infinity_timers
	local cur_time = game.get_time()

	timers[token_id] = math.max(timers[token_id] or cur_time, cur_time) + seconds
end


--- Return is token is infinity now
-- @function eva.token.is_infinity
function M.is_infinity(container_id, token_id)
	return M.get_infinity_seconds(container_id, token_id) > 0
end


--- Get amount of seconds till end of infinity time
-- @function eva.token.get_infinity_seconds
function M.get_infinity_seconds(container_id, token_id)
	local end_timer = get_data_containers()[container_id].infinity_timers[token_id]
	if end_timer then
		return math.ceil(end_timer - game.get_time())
	end

	return 0
end


--- Reset visual debt of tokens
-- @function eva.token.sync_visual
function M.sync_visual(container_id, token_id)
	return get_token(container_id, token_id):sync_visual()
end


--- Add visual debt to token
-- @function eva.token.add_visual
function M.add_visual(container_id, token_id, amount)
	return get_token(container_id, token_id):add_visual(amount)
end


--- Get current visual debt of token
-- @function eva.token.get_visual
function M.get_visual(container_id, token_id)
	return get_token(container_id, token_id):get_visual()
end


--- Get current time to next restore point
-- @function eva.token.get_seconds_to_restore
function M.get_seconds_to_restore(container_id, token_id)
	local config = M.get_restore_config(container_id, token_id)

	if not config then
		logger:warn("Get seconds to restore from token without restore", {
			container_id = container_id,
			token_id = token_id
		})
		return 0
	end

	local last = config.last_restore_time
	local skipped = game.get_time() - last

	return math.max(0, config.timer - skipped)
end


function M.before_eva_init()
	app.smart_containers = {}
end


function M.on_eva_init()
	app[const.EVA.CONTAINERS] = proto.get(const.EVA.CONTAINERS)
	saver.add_save_part(const.EVA.CONTAINERS, app[const.EVA.CONTAINERS])

	events.subscribe(const.EVENT.GAME_FOCUS, update_tokens_offset)
end


function M.after_eva_init()
	local containers = app.smart_containers
	local data_containers = get_data_containers()
	for container_id, data_container in pairs(data_containers) do
		containers[container_id] = containers[container_id] or {}

		for token_id, token_data in pairs(data_container.tokens) do
			-- Link behavior and data
			local container = containers[container_id]
			container[token_id] = create_token_in_save(container_id, token_id, token_data)
		end
	end
end


local function restore_token_update(container_id, token_id, config)
	local token = get_token(container_id, token_id)

	local cur_time = game.get_time()
	config.last_restore_time = math.min(config.last_restore_time, cur_time)
	if token:is_max() then
		config.last_restore_time = cur_time
	end

	local elapsed = cur_time - config.last_restore_time
	if elapsed >= config.timer then
		local amount = math.floor(elapsed / config.timer)
		local need_to_add = amount * config.value

		if config.max then
			need_to_add = math.min(need_to_add, config.max)
		end
		token:add(need_to_add)

		local cur_elapse_time = elapsed - (amount * config.timer)
		config.last_restore_time = cur_time - cur_elapse_time
	end
end


function M.on_eva_update(dt)
	local containers = get_data_containers()
	for container_id, container in pairs(containers) do
		local restore_config = container.restore_config
		for token_id, config in pairs(restore_config) do
			if config.is_enabled then
				restore_token_update(container_id, token_id, config)
			end
		end
	end
end


return M