--- Eva device module
-- Contains stuff to work with device info
-- @submodule eva


local app = require("eva.app")
local log = require("eva.log")
local luax = require("eva.luax")
local const = require("eva.const")
local uuid = require("eva.libs.uuid")

local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local logger = log.get_logger("eva.device")

local M = {}


--- Return device id.
-- If device_id is empty, it will generate device_id with
-- uuid library. And store it on file
-- @function eva.device.get_device_id
-- @treturn string device_id
function M.get_device_id()
	local data = app[const.EVA.DEVICE]
	if data.device_id == "" then
		if M.is_mobile() then
			local sys_info = sys.get_sys_info()
			data.device_id = sys_info.device_ident
			logger:debug("Get new device_id", { device_id = data.device_id })
		end

		if #data.device_id <= 2 then
			data.device_id = M.get_uuid()
			logger:debug("Generate device_id from uuid", { device_id = data.device_id })
		end
	end

	return data.device_id
end


--- Generate uuid
-- @function eva.device.get_uuid
-- @tparam table except list of uuid, what not need to be generated
-- @treturn string the uuid
function M.get_uuid(except)
	if not except then
		return uuid()
	else
		while true do
			local id = uuid()
			if not luax.table.contains(except) then
				return id
			end
		end
	end
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


--- Check if device is native mobile (Android or iOS)
-- @function eva.device.is_mobile
function M.is_mobile()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.IOS or system_name == const.OS.ANDROID
end


--- Check if device is desktop (Windows/MacOS)
-- @function eva.device.is_desktop
function M.is_desktop()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.MAC or system_name == const.OS.WINDOWS
end


--- Check if device is HTML5
-- @function eva.device.is_web
function M.is_web()
	local system_name = sys.get_sys_info().system_name
	return system_name == const.OS.BROWSER
end


--- Check if device is HTML5 mobile
-- @function eva.device.is_web_mobile
function M.is_web_mobile()
	if html5 then
		return html5.run("(typeof window.orientation !== 'undefined') || (navigator.userAgent.indexOf('IEMobile') !== -1);") == "true"
	end
	return false
end


function M.on_eva_init()
	uuid.randomseed(socket.gettime() * 10000)

	app[const.EVA.DEVICE] = proto.get(const.EVA.DEVICE)
	saver.add_save_part(const.EVA.DEVICE, app[const.EVA.DEVICE])

	local device_id = M.get_device_id()
	logger:info("Device ID", { device_id = device_id })
end


return M
