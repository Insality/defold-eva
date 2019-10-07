--- Eva lang module
-- API to work with game localization
-- @submodule eva


local const = require("eva.const")


local M = {}

local function load_lang(lang)
	local settings = M._eva.app.settings.lang
	local filename = settings.lang_paths[lang]
	M._eva.app.lang_dict = M._eva.utils.load_json(filename)
end


--- Set current language
-- @function eva.lang.set_lang
-- @tparam string lang current language code from eva-settings
function M.set_lang(lang)
	load_lang(lang)
	M._eva.app[const.EVA.LANG].lang = lang
	M._eva.events.event(const.EVENT.LANG_UPDATE, { lang = lang })
end


--- Get current language
-- @function eva.lang.get_lang
-- @treturn string return current language code
function M.get_lang()
	return M._eva.app[const.EVA.LANG].lang
end


--- Get translation for locale id
-- @function eva.lang.txt
-- @tparam string lang_id locale id from your localization
-- @treturn string translated locale
function M.txt(lang_id)
	assert(lang_id, "You must provide the lang id")
	return M._eva.app.lang_dict[lang_id] or lang_id
end


--- Get translation for locale id with params
-- @function eva.lang.txp
-- @tparam string lang_id locale id from your localization
-- @tparam string ... params for string.format for lang_id
-- @treturn string translated locale
function M.txp(lang_id, ...)
	assert(lang_id, "You must provide the lang id")
	return string.format(M.txt(lang_id), ...)
end


function M.on_game_start()
	local settings = M._eva.app.settings.lang
	local default_lang = settings.default
	local device_lang = string.sub(sys.get_sys_info().device_language, 1, 2)

	if settings.lang_paths[device_lang] then
		default_lang = device_lang
	end

	M._eva.app[const.EVA.LANG] = M._eva.proto.get(const.EVA.LANG)
	M._eva.app[const.EVA.LANG].lang = default_lang

	M._eva.saver.add_save_part(const.EVA.LANG, M._eva.app[const.EVA.LANG])
end


function M.after_game_start()
	M.set_lang(M._eva.app[const.EVA.LANG].lang)
end


return M
