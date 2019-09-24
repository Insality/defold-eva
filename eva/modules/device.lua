local log = require("eva.log")
local const = require("eva.const")

local logger = log.get_logger("eva.device")

local M = {}


function M.get_device_id()
	if M._device_prefs.device_id == "" then
		if M.is_mobile() then
			local sys_info = sys.get_sys_info()
			M._device_prefs.device_id = sys_info.device_ident
			logger:debug("Get new device_id", { device_id = M._device_prefs.device_id })
		end

		if #M._device_prefs.device_id < 8 then
			M._device_prefs.device_id = M._eva.game.get_uuid()
			logger:debug("Generate device_id from uuid", { device_id = M._device_prefs.device_id })
		end
	end

	return M._device_prefs.device_id
end


function M.get_region()
	local sys_info = sys.get_sys_info()
	local region = sys_info.territory
	if #region ~= 2 then
		return const.UNKNOWN_REGION
	end

	return region:upper()
end


function M.get_device_info()
	local info = sys.get_sys_info()
	local engine_info = sys.get_engine_info()
	local device_info = {
		device_model = info.device_model,
		manufacturer = info.manufacturer,
		system_name = info.system_name,
		system_version = info.system_version,
		api_version = info.api_version,
		language = info.language,
		device_language = info.device_language,
		territory = info.territory,
		device_ident = info.device_ident,
		gmt_offset = tostring(info.gmt_offset),
		ad_tracking_enabled = tostring(info.ad_tracking_enabled),
		defold_version = engine_info.version,
	}

	return device_info
end


function M.is_android()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.ANDROID
end


function M.is_ios()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS
end


function M.is_mobile()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS or system_name == const.OS.ANDROID
end


function M.before_game_start(settings)
	M._device_prefs = M._eva.proto.get(const.EVA.DEVICE)
	M._eva.saver.add_save_part(const.EVA.DEVICE, M._device_prefs)
end


function M.after_game_start(settings)
	local device_id = M.get_device_id()
	logger:info("Device ID", { device_id = device_id })
end


return M
