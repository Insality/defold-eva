--- Eva lang module
-- API to work with game localization
-- @submodule eva


local app = require("eva.app")
local luax = require("eva.luax")
local const = require("eva.const")

local utils = require("eva.modules.utils")
local events = require("eva.modules.events")
local proto = require("eva.modules.proto")
local saver = require("eva.modules.saver")

local M = {}
local EMPTY_STRING = ""

local function load_lang(lang)
	local settings = app.settings.lang
	local filename = settings.lang_paths[lang]

	app.clear("lang_dict")
	app.lang_dict = utils.load_json(filename) or {}
end


local function get_time_data(seconds)
	local minutes = math.max(0, math.floor(seconds / 60))
	seconds = math.max(0, math.floor(seconds % 60))
	local hours = math.max(0, math.floor(minutes / 60))
	minutes = math.max(0, math.floor(minutes % 60))
	local days = math.max(0, math.floor(hours / 24))
	hours = math.max(0, math.floor(hours % 24))

	return days, hours, minutes, seconds
end


--- Return localized time format from seconds
-- @function eva.lang.time_format
function M.time_format(seconds)
	local days, hours, minutes, secs = get_time_data(seconds)
	if days > 0 then
		return M.txp("time_format_d", days, hours, minutes, secs)
	elseif hours > 0 then
		return M.txp("time_format_h", hours, minutes, secs)
	else
		return M.txp("time_format_m", minutes, secs)
	end
end


--- Set current language
-- @function eva.lang.set_lang
-- @tparam string lang current language code from eva-settings
function M.set_lang(lang)
	load_lang(lang)
	if app[const.EVA.LANG].lang ~= lang then
		app[const.EVA.LANG].lang = lang
		events.event(const.EVENT.LANG_UPDATE, { lang = lang })
	end
end


function M.set_next_lang()
	local current_lang = M.get_lang()
	local all_langs = M.get_langs()
	local current_index = luax.table.contains(all_langs, current_lang) or 1
	if current_index >= #all_langs then
		current_index = 1
	else
		current_index = current_index + 1
	end
	M.set_lang(all_langs[current_index])
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


--- Get random translation for locale id, split by \n symbol
-- @function eva.lang.txr
-- @tparam string lang_id locale id from your localization
-- @treturn string translated locale
function M.txr(lang_id)
	assert(lang_id, "You must provide the lang id")
	if not app.lang_dict[lang_id] then
		return lang_id
	end
	local texts = luax.string.split(app.lang_dict[lang_id], "\n")
	return texts[math.random(1, #texts)]
end


--- Get translation for locale id with params
-- @function eva.lang.txp
-- @tparam string lang_id Locale id from your localization
-- @tparam string ... Params for string.format for lang_id
-- @treturn string Translated locale
function M.txp(lang_id, a, b, c, d, e, f, g)
	assert(lang_id, "You must provide the lang id")
	return string.format(M.txt(lang_id),
		a or EMPTY_STRING,
		b or EMPTY_STRING,
		c or EMPTY_STRING,
		d or EMPTY_STRING,
		e or EMPTY_STRING,
		f or EMPTY_STRING,
		g or EMPTY_STRING)
end


--- Check is translation with lang_id exist
-- @function eva.lang.is_exist
-- @tparam strng lang_id Locale id from your localization
-- @treturn bool Is translation exist
function M.is_exist(lang_id)
	return luax.toboolean(app.lang_dict[lang_id])
end


--- Return list of available languages
-- @function eva.lang.get_langs
-- @treturn table List of available languages
function M.get_langs()
	return luax.table.list(app.settings.lang.lang_paths)
end


function M.on_eva_init()
	local settings = app.settings.lang
	local default_lang = settings.default
	local device_lang = string.sub(sys.get_sys_info().device_language, 1, 2)

	if settings.lang_paths[device_lang] then
		default_lang = device_lang
	end

	app[const.EVA.LANG] = proto.get(const.EVA.LANG)
	app[const.EVA.LANG].lang = default_lang

	saver.add_save_part(const.EVA.LANG, app[const.EVA.LANG])
end


function M.after_eva_init()
	M.set_lang(app[const.EVA.LANG].lang)
end


return M
