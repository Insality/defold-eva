--- Eva server module
-- Take all fucntions on client-server communication
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")
local Event = require("eva.event")

local game = require("eva.modules.game")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local server_nakama_helper = require("eva.modules.server.server_nakama_helper")

local logger = log.get_logger("eva.server")


local M = {}


--- Reset utilities data on connect to the server
-- @local
local function on_connected()
	app.server_data.last_connection_time = game.get_time()
	app.server_data.connection_attempt = 0
end


--- Schedule the next reconnect server timer
-- @local
local function schedule_reconnect()
	app.server_data.connection_attempt = app.server_data.connection_attempt + 1
	local reconnect_time = app.settings.server.reconnect_attempts_time

	local index = luax.math.clamp(app.server_data.connection_attempt, 1, #reconnect_time)
	local time = reconnect_time[index]

	if app.server_data.reconnect_timer_id then
		timer.cancel(app.server_data.reconnect_timer_id)
	end

	app.server_data.reconnect_timer_id = timer.delay(time, false, function()
		app.server_data.reconnect_timer_id = nil
		server_nakama_helper.connect(app.server_data.nakama_config, app.server_data.nakama_socket, app[const.EVA.SERVER].token)
	end)

	logger:info("Schedule reconnect", { time = time, attempt = app.server_data.connection_attempt })
end


--- The daemon to check server sessions and reconnections
-- @local
local function connection_daemon()
	if app.server_data.is_connected or app.server_data.reconnect_timer_id or app.server_data.is_connecting then
		server_nakama_helper.refresh_session()
		return
	end
	server_nakama_helper.connect(app.server_data.nakama_config, app.server_data.nakama_socket, app[const.EVA.SERVER].token)
end


--- Login at nakama server
-- @function eva.server.connect
-- @tparam function callback Callback after login
function M.connect(callback)
	local settings = app.settings.server
	if settings.is_disabled then
		logger:debug("The server is disabled")
		return
	end

	local host = settings.server_host
	local port = settings.server_port
	local ssl = settings.use_ssl
	logger:debug("Start connection to Nakama server", { host = host, port = port, ssl = ssl })

	server_nakama_helper.connect(app.server_data.nakama_config, app.server_data.nakama_socket, app[const.EVA.SERVER].token, function()
		on_connected()
		if callback then
			callback(app.server_data.nakama_session)
		end
	end)
end


--- Return is currently server connected
-- @function eva.server.is_connected
-- @treturn boolean If server connected
function M.is_connected()
	return app.server_data.is_connected
end


--- Return nakama client
-- @function eva.server.get_client
-- @treturn table
function M.get_client()
	return app.server_data.nakama_config
end


--- Return nakama socket
-- @function eva.server.get_socket
-- @treturn table
function M.get_socket()
	return app.server_data.nakama_socket
end


function M.before_eva_init()
	server_nakama_helper.init_dependencies()

	local settings = app.settings.server
	app.server_data = {
		nakama_config = server_nakama_helper.create_nakama_client(settings.server_host, settings.server_port, settings.use_ssl),
		nakama_socket = nil,
		nakama_session = nil,
		last_connection_time = nil,
		connection_attempt = 0,
		reconnect_timer_id = nil,
		daemon_timer_id = nil,
		is_connected = false,
		is_connecting = false,
	}
	app.server_events = {
		event_disconnect = Event(),
		event_error = Event(),
		event_notification = Event(),
		event_matchdata = Event(),
		event_matchpresence = Event(),
		event_matchmakermatched = Event(),
		event_statuspresence = Event(),
		connect_status = Event(),
	}
	app.server_data.nakama_socket = server_nakama_helper.create_nakama_socket(app.server_data.nakama_config)

	server_nakama_helper.before_eva_init(app.server_data.nakama_config, app.server_data.nakama_socket)
end


function M.on_eva_init()
	app[const.EVA.SERVER] = proto.get(const.EVA.SERVER)
	saver.add_save_part(const.EVA.SERVER, app[const.EVA.SERVER])

	app.server_events.event_disconnect:subscribe(function()
		schedule_reconnect()
	end)

	app.server_data.daemon_timer_id = timer.delay(app.settings.server.check_connection_timer, true, connection_daemon)
end


return M
