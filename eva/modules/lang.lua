--- Eva lang module
-- API to work with game localization
-- @submodule eva


local app = require("eva.app")
local const = require("eva.const")


local M = {}

local function load_lang(lang)
	local settings = app.settings.lang
	local filename = settings.lang_paths[lang]
	app.lang_dict = M._eva.utils.load_json(filename)
end


--- Set current language
-- @function eva.lang.set_lang
-- @tparam string lang current language code from eva-settings
function M.set_lang(lang)
	load_lang(lang)
	app[const.EVA.LANG].lang = lang
	M._eva.events.event(const.EVENT.LANG_UPDATE, { lang = lang })
end


--- Get current language
-- @function eva.lang.get_lang
-- @treturn string return current language code
function M.get_lang()
	return app[const.EVA.LANG].lang
end


--- Get translation for locale id
-- @function eva.lang.txt
-- @tparam string lang_id locale id from your localization
-- @treturn string translated locale
function M.txt(lang_id)
	assert(lang_id, "You must provide the lang id")
	return app.lang_dict[lang_id] or lang_id
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


function M.on_eva_init()
	local settings = app.settings.lang
	local default_lang = settings.default
	local device_lang = string.sub(sys.get_sys_info().device_language, 1, 2)

	if settings.lang_paths[device_lang] then
		default_lang = device_lang
	end

	app[const.EVA.LANG] = M._eva.proto.get(const.EVA.LANG)
	app[const.EVA.LANG].lang = default_lang

	M._eva.saver.add_save_part(const.EVA.LANG, app[const.EVA.LANG])
end


function M.after_eva_init()
	M.set_lang(app[const.EVA.LANG].lang)
end


return M
