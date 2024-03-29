--- Eva utils module
-- Contains simple helpers functions to
-- make your life easier
-- @submodule eva

local const = require("eva.const")

local events = require("eva.modules.events")

local M = {}


--- Make after closure
-- @function eva.utils.after
function M.after(count, callback)
	local closure = function()
		count = count - 1
		if count <= 0 then
			callback()
		end
	end

	return closure
end


--- Save json in bundled resource (desktop only)
-- @function eva.utils.save_json
function M.save_json(lua_table, filepath)
	local file, errors = io.open(filepath, "w+")
	if not file then
		pprint(errors)
	end
	file:write(cjson.encode(lua_table))
	file:close()
end


--- Load json from bundled resource
-- @function eva.utils.load_json
function M.load_json(filepath)
	local resource, is_error = sys.load_resource(filepath)
	if is_error then
		return nil
	end

	return cjson.decode(resource)
end


--- Convert hex color to rgb color
-- @function eva.utils.hex2rgb
function M.hex2rgb(hex, alpha)
	alpha = alpha or 1
	local redColor,greenColor,blueColor = hex:match('(..)(..)(..)')
	redColor, greenColor, blueColor = tonumber(redColor, 16)/255, tonumber(greenColor, 16)/255, tonumber(blueColor, 16)/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100

	if alpha > 1 then
		alpha = alpha / 100
	end

	return redColor, greenColor, blueColor, alpha
end


--- Convert rgb color to hex color
-- @function eva.utils.rgb2hex
function M.rgb2hex(r, g, b, alpha)
	alpha = alpha or 1
	local redColor,greenColor,blueColor = r/255, g/255, b/255
	redColor, greenColor, blueColor = math.floor(redColor*100)/100, math.floor(greenColor*100)/100, math.floor(blueColor*100)/100

	if alpha > 1 then
		alpha = alpha / 100
	end

	return redColor, greenColor, blueColor, alpha
end


--- Return days in month
-- @function eva.utils.get_days_in_month
function M.get_days_in_month(month, year)
	local is_leap_year = year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0)

	if month == 2 and is_leap_year then
		return 29
	else
		return const.DAYS_IN_MONTH[month]
	end
end


--- Load image to GUI node
-- @function eva.utils.load_image
local __image_cache = {}
function M.load_image(node, image_path, image_id)
	local place_url = msg.url()
	local place_id = place_url.socket .. place_url.path

	__image_cache[place_id] = __image_cache[place_id] or {}

	image_id = image_id or image_path
	if __image_cache[place_id][image_id] then
		gui.set_texture(node, image_id)
		return true, "Set from cache texture"
	end

	local resource_data, is_error = sys.load_resource(image_path)
	if is_error then
		return nil, is_error
	end

	local img = image.load(resource_data)
	if not img then
		return nil, "Unable to load image"
	end

	if gui.new_texture(image_id, img.width, img.height, img.type, img.buffer) then
		__image_cache[place_id][image_id] = image_id
		gui.set_texture(node, image_id)
		return true, "Set new texture"
	else
		return nil, "Unable to create texture"
	end
end


local function clear_texture_cache()
	__image_cache = {}
end


function M.on_eva_init()
	events.subscribe(const.EVENT.SCENE_SHOW, clear_texture_cache)
end


return M
