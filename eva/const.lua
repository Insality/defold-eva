local M = {}

M.UNKNOWN_REGION = "UN"


M.MSG = {
	EVENT = hash("eva.event"),
	SMART_VALUE_UPDATE = hash("eva.smartvalue.update")
}


M.OS = {
	ANDROID = "Android",
	IOS = "iPhone OS",
	MAC = "Darwin",
	LINUX = "Linux",
	WINDOWS = "Windows",
	BROWSER = "HTML5",
}


M.OS.MOBILE_PLATFORMS = {
	M.OS.ANDROID,
	M.OS.IOS,
}


M.OS.PC_PLATFORMS = {
	M.OS.MAC,
	M.OS.LINUX,
	M.OS.WINDOWS,
	M.OS.BROWSER,
}


return M