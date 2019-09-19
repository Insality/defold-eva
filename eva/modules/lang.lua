local const = require("eva.const")
local broadcast = require("eva.libs.broadcast")
local settings = require("eva.settings.default").settings

local M = {}

local dict = {}
local lang_prefs = {
	lang = settings.lang.default
}


local function load_lang(lang)
	local filename = settings.lang.langs_path .. lang .. ".json"
	dict = cjson.decode(sys.load_resource(filename))
end


function M.set_lang(lang)
	load_lang(lang)
	lang_prefs.lang = lang
	broadcast.send(const.MSG.LANG_UPDATE)
end


function M.get_lang()
	return lang_prefs.lang
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
	M._eva.saver.add_save_part("eva.lang", lang_prefs)
end


return M
