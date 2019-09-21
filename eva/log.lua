local luax = require("eva.luax")
local settings = require("eva.settings.default")

local M = {}
local _loggers = {}
local _log = {}

local LEVEL = {
	FATAL = 10,
	ERROR = 20,
	WARN = 30,
	INFO = 40,
	DEBUG = 50,
}

local LEVEL_NAME = {
	[LEVEL.FATAL] = "FATAL",
	[LEVEL.ERROR] = "ERROR",
	[LEVEL.WARN]= "WARN",
	[LEVEL.INFO]= "INFO",
	[LEVEL.DEBUG] = "DEBUG",
}


local function format_time(time)
	local seconds, milliseconds = math.modf(time)
	local date_string = os.date("%H:%M:%S.", seconds) .. string.format("%03i", milliseconds * 1000)
	return date_string
end


local function format(self, level, message, context)
	local log_message = settings.log.format
	local record_context = ""
	if context and luax.table.length(context) ~= 0 then
		for k, v in pairs(context) do
			record_context = string.format("%s %s=%s", record_context, k, v)
		end
		record_context = string.format("{%s }", record_context)
	end

	local caller_info = debug.getinfo(4)
	log_message = string.gsub(log_message, "%%date", format_time(socket.gettime()))
	log_message = string.gsub(log_message, "%%levelname", string.format("%5s", LEVEL_NAME[level]))
	log_message = string.gsub(log_message, "%%logger", self.name)
	log_message = string.gsub(log_message, "%%source", caller_info.source)
	log_message = string.gsub(log_message, "%%lineno", caller_info.currentline)
	log_message = string.gsub(log_message, "%%function", caller_info.short_src)
	log_message = string.gsub(log_message, "%%fname", caller_info.name)
	log_message = string.gsub(log_message, "%%message", message)
	log_message = string.gsub(log_message, "%%context", record_context)

	return log_message
end


local function log_msg(self, level, message, context)
	message = format(self, level, message, context)
	io.stdout:write(message .. "\n")
	io.stdout:flush()
end


function _log.fatal(self, msg, context)
	log_msg(self, LEVEL.FATAL, msg, context)
end


function _log.error(self, msg, context)
	log_msg(self, LEVEL.ERROR, msg, context)
end


function _log.warn(self, msg, context)
	log_msg(self, LEVEL.WARN, msg, context)
end


function _log.info(self, msg, context)
	log_msg(self, LEVEL.INFO, msg, context)
end


function _log.debug(self, msg, context)
	log_msg(self, LEVEL.DEBUG, msg, context)
end


function M.get_logger(name)
	name = name or "default"
	_loggers[name] = _loggers[name] or setmetatable({}, { __index = _log })
	_loggers[name].name = name
	return _loggers[name]
end


return M
