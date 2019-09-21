local const = require("eva.const")
local broadcast = require("eva.libs.broadcast")
local settings = require("eva.settings.default")

local M = {}
local dict = {}

local function load_lang(lang)
	local filename = settings.lang.lang_paths[lang]
	dict = cjson.decode(sys.load_resource(filename))
end


function M.set_lang(lang)
	load_lang(lang)
	M._lang_prefs.lang = lang
	broadcast.send(const.MSG.LANG_UPDATE)
end


function M.get_lang()
	return M._lang_prefs.lang
end


function M.txt(lang_id)
	assert(lang_id, "You must provide the lang id")
	return dict[lang_id] or lang_id
end


function M.txp(lang_id, ...)
	assert(lang_id, "You must provide the lang id")
	return string.format(M.txt(lang_id), ...)
end


function M.on_game_start()
	local default_lang = settings.lang.default
	local device_lang = string.sub(sys.get_sys_info().device_language, 1, 2)

	if settings.lang.lang_paths[device_lang] then
		default_lang = device_lang
	end

	M._lang_prefs = M._eva.proto.get("eva.Lang")
	M._lang_prefs.lang = default_lang

	M._eva.saver.add_save_part("eva.Lang", M._lang_prefs)
end


function M.after_game_start()
	M.set_lang(M._lang_prefs.lang)
end


return M
