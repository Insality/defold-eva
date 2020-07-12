--- Eva utils module
-- Contains simple helpers functions to
-- make your life easier
-- @submodule eva

local const = require("eva.const")

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


--- Load json from bundled resource
-- @function eva.utils.load_json
function M.load_json(filename)
	return cjson.decode(sys.load_resource(filename))
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


return M
