--- Adapter for nakama server
-- @module nakama_helper
-- @local

local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")

--- This dependencies will be overriden if server is enabled
local defold = nil
local nakama = nil
local nakama_session = nil
local nakama_log = nil

local device = require("eva.modules.device")

local logger = log.get_logger("nakama")

local M = {}


local function on_disconnect(message)
	logger:debug("Server disconnected")
	app.server_data.is_connected = false
	app.server_events.event_disconnect:trigger(message)
	app.server_events.connect_status:trigger(false)
end


local function on_notification(message)
	local data = message.notifications.notifications or {}
	app.server_events.event_notification:trigger(data)
end


local function on_matchdata(message)
	app.server_events.event_matchdata:trigger(message)
end


local function on_matchpresence(message)
	app.server_events.event_matchpresence:trigger(message)
end


local function on_matchmakermatched(message)
	app.server_events.event_matchmakermatched:trigger(message)
end


local function on_statuspresence(message)
	app.server_events.event_statuspresence:trigger(message)
end


local function bind_callbacks(client, socket)
	nakama.on_disconnect(socket, on_disconnect)
	nakama.on_notification(socket, on_notification)
	nakama.on_matchdata(socket, on_matchdata)
	nakama.on_matchpresence(socket, on_matchpresence)
	nakama.on_matchmakermatched(socket, on_matchmakermatched)
	nakama.on_statuspresence(socket, on_statuspresence)
end


local function set_session_token(client, session)
	if session and session.token then
		app[const.EVA.SERVER].token = session.token
		app.server_data.nakama_session = session
		nakama.set_bearer_token(client, session.token)
	else
		app[const.EVA.SERVER].token = ""
		app.server_data.nakama_session = nil
	end
end


local function is_token_empty(token)
	return not token or token == ""
end


local function is_session_expire_soon(session)
	local time_to_expire = (session.expires - os.time())
	return time_to_expire < app.settings.server.check_connection_timer * 5
end


local function auth(client)
	local uid = device.get_device_id()
	local body = nakama.create_api_account_device(uid)
	logger:debug("Auth started", { id = uid })

	local session = nakama.authenticate_device(client, body, true, uid)
	if not session.token then
		logger:info("Auth failed, no session")
		return nil
	end

	set_session_token(client, session)

	logger:debug("Authenticated", { token = session.token, user_id = session.user_id })
	return session.token
end


local function check_new_user(client, token)
	if is_token_empty(token) then
		logger:debug("Auth for new user")
		token = auth(client)
	end

	return token
end


local function check_session(client, token)
	local session = nakama_session.create({ token = token })
	if is_session_expire_soon(session) then
		logger:info("Session has expired, call reauth")
		token = auth(client)
	else
		logger:debug("Session token is valid")
		set_session_token(client, session)
	end
	return token
end


local function socket_connect(client, socket, callback)
	local socket_connected, socket_error = nakama.socket_connect(socket)
	app.server_data.is_connecting = false

	if socket_connected then
		logger:info("Socket connected")
		app.server_data.is_connected = true
		app.server_events.connect_status:trigger(true)
		if callback then
			callback()
		end
	else
		logger:error("Socket error", { error = socket_error })
		set_session_token(nil)

		if luax.string.ends(socket_error, "401") then
			logger:info("Token expired, reset")
			M.connect(client, socket, nil, callback)
		end
	end
end


--- Return nakama client config
-- @function nakama_helper.create_nakama_client
-- @treturn string host
-- @treturn number port
-- @treturn boolean is_ssl
-- @treturn table The nakama client config
-- @local
function M.create_nakama_client(host, port, is_ssl)
	if app.settings.server.debug_log then
		nakama_log.custom(function(text, a, b)
			logger:debug(text, { a = a, b = b})
		end)
	end

	local config = {
		host = host,
		port = port,
		use_ssl = is_ssl,
		username = app.settings.server.server_key,
		password = "",
		engine = defold,
		timeout = 10, -- connection timeout in seconds
	}
	return nakama.create_client(config)
end


--- Return nakama socket client
-- @function nakama_helper.create_nakama_socket
-- @tparam table client The nakama client config
-- @treturn table The nakama socket config
-- @local
function M.create_nakama_socket(client)
	local socket = nakama.create_socket(client)
	return socket
end


--- Start connect to the nakama server
-- @function nakama_helper.connect
-- @tparam table client The nakama client config
-- @tparam table socket The nakama socket config
-- @tparam string token The nakama client token
-- @tparam function callback The callback after the login
-- @local
function M.connect(client, socket, token, callback)
	if app.server_data.is_connected then
		logger:error("Call server connect while already connected")
		return
	end

	app.server_data.is_connecting = true
	nakama.sync(function()
		token = check_new_user(client, token)

		if is_token_empty(token) then
			logger:warn("Can't auth on server")
			app.server_data.is_connecting = false
			return nil
		end

		token = check_session(client, token)

		if is_token_empty(token) then
			logger:warn("Can't auth on server, drop the connection flow")
			app.server_data.is_connecting = false
			return nil
		end

		socket_connect(client, socket, callback)
	end)
end


--- Check and update if required the nakama session
-- @function nakama_helper.refresh_session
-- @local
function M.refresh_session()
	local session = app.server_data.nakama_session
	if not session or is_session_expire_soon(session) then
		logger:debug("Session token will expire soon, refresh")
		nakama.sync(function()
			auth(app.server_data.nakama_config)
		end)
	end
end


function M.init_dependencies()
	-- Override dynamic dependencies
	defold = const.require("nakama.engine.defold")
	nakama = const.require("nakama.nakama")
	nakama_session = const.require("nakama.session")
	nakama_log = const.require("nakama.util.log")
end


function M.before_eva_init(client, socket)
	bind_callbacks(client, socket)

	app.server_data.is_connected = false
	app.server_data.is_connecting = false
end


return M
