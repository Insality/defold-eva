--- Defold-Eva device module
-- Contains stuff to work with device info
-- @submodule eva

local log = require("eva.log")
local const = require("eva.const")

local logger = log.get_logger("eva.device")

local M = {}


--- Return device id.
-- If device_id is empty, it will generate device_id with
-- uuid library. And store it on file
-- @function eva.device.get_device_id
-- @treturn string device_id
function M.get_device_id()
	local data = M._eva.app[const.EVA.DEVICE]
	if data.device_id == "" then
		if M.is_mobile() then
			local sys_info = sys.get_sys_info()
			data.device_id = sys_info.device_ident
			logger:debug("Get new device_id", { device_id = data.device_id })
		end

		if #data.device_id < 8 then
			data.device_id = M._eva.game.get_uuid()
			logger:debug("Generate device_id from uuid", { device_id = data.device_id })
		end
	end

	return data.device_id
end


--- Return device region.
-- If region is unknown, it will return "UN".
-- @function eva.device.get_region
-- @treturn string region
function M.get_region()
	local sys_info = sys.get_sys_info()
	local region = sys_info.territory
	if #region ~= 2 then
		return const.UNKNOWN_REGION
	end

	return region:upper()
end


--- Return device_info
-- @function eva.device.get_device_info
function M.get_device_info()
	local info = sys.get_sys_info()
	local engine_info = sys.get_engine_info()
	local device_info = {
		language = info.language,
		territory = info.territory,
		api_version = info.api_version,
		system_name = info.system_name,
		device_ident = info.device_ident,
		device_model = info.device_model,
		manufacturer = info.manufacturer,
		system_version = info.system_version,
		device_language = info.device_language,
		gmt_offset = tostring(info.gmt_offset),
		ad_tracking_enabled = tostring(info.ad_tracking_enabled),

		defold_version = engine_info.version,
	}

	return device_info
end


--- Check if device on android
-- @function eva.device.is_android
function M.is_android()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.ANDROID
end


--- Check if device on iOS
-- @function eva.device.is_ios
function M.is_ios()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS
end


--- Check if device is mobile (Android or iOS)
-- @function eva.device.is_mobile
function M.is_mobile()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS or system_name == const.OS.ANDROID
end


function M.is_web()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.BROWSER
end


function M.on_game_start()
	M._eva.app[const.EVA.DEVICE] = M._eva.proto.get(const.EVA.DEVICE)
	M._eva.saver.add_save_part(const.EVA.DEVICE, M._eva.app[const.EVA.DEVICE])

	local device_id = M.get_device_id()
	logger:info("Device ID", { device_id = device_id })
end


return M
