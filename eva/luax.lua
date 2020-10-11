--- Defold Lua extended module

local M = {
	go = {},
	gui = {},
	string = {},
	math = {},
	table = {},
	vmath = {},
	debug = {},
	func = {},
	toboolean = function(arg) return not not arg end,
}


M.go.PROP_POS = "position"
M.go.PROP_POS_X = "position.x"
M.go.PROP_POS_Y = "position.y"
M.gui.PROP_POS = "position"
M.gui.PROP_POS_X = "position.x"
M.gui.PROP_POS_Y = "position.y"
M.gui.PROP_ALPHA = "color.w"
M.gui.PROP_SCALE_X = "scale.x"
M.gui.PROP_SCALE_Y = "scale.y"
M.vmath.VECTOR_ZERO = vmath.vector3(0)
M.vmath.VECTOR_ONE = vmath.vector3(1)
M.table.empty = {}
M.string.empty = ""
M.func.empty = function() end


--- math.step
-- @function luax.math.step
function M.math.step(current, target, step)
	if current < target then
		return math.min(current + step, target)
	else
		return math.max(target, current - step)
	end
end


--- math.sign
-- @function luax.math.sign
function M.math.sign(value)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	else
		return 0
	end
end


--- math.lerp
-- @function luax.math.lerp
function M.math.lerp(a, b, t)
	return a + (b - a) * t
end


--- math.lerp_box
-- @function luax.math.lerp_box
function M.math.lerp_box(pos, box, lerp, size, change_point)
	size = size or M.vmath.VECTOR_ZERO

	local new_point = change_point and pos or vmath.vector3(pos)

	if new_point.x < box.x + size.x/2 then
		new_point.x = M.math.lerp(new_point.x, box.x + size.x/2, lerp)
	end
	if new_point.x > box.z - size.x/2 then
		new_point.x = M.math.lerp(new_point.x, box.z - size.x/2, lerp)
	end
	if new_point.y < box.y + size.y/2 then
		new_point.y = M.math.lerp(new_point.y, box.y + size.y/2, lerp)
	end
	if new_point.y > box.w - size.y/2 then
		new_point.y = M.math.lerp(new_point.y, box.w - size.y/2, lerp)
	end

	return new_point
end


--- math.clamp
-- @function luax.math.clamp
function M.math.clamp(a, min, max)
	if min > max then
		min, max = max, min
	end

	if a >= min and a <= max then
		return a
	elseif a < min then
		return min
	else
		return max
	end
end


--- math.clamp_box
-- @function luax.math.clamp_box
-- @tparam vector3 pos
-- @tparam vector4 box
-- @tparam[opt] vector3 size
-- @tparam[opt] bool change_point
function M.math.clamp_box(pos, box, size, change_point)
	size = size or M.vmath.VECTOR_ZERO

	local new_point = change_point and pos or vmath.vector3(pos)
	new_point.x = M.math.clamp(new_point.x, box.x + size.x/2, box.z - size.x/2)
	new_point.y = M.math.clamp(new_point.y, box.y + size.y/2, box.w - size.y/2)

	return new_point
end


--- math.round
-- @function luax.math.round
function M.math.round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


--- math.is
-- @function luax.math.is
function M.math.is(value, ...)
	for i = 1, select("#", ...) do
		if value == select(i, ...) then
			return true
		end
	end
	return false
end


--- math.chance
-- @function luax.math.chance
function M.math.chance(percent)
	return math.random() <= percent
end


--- math.distance
-- @function luax.math.distance
function M.math.distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


--- math.manhattan
-- @function luax.math.manhattan
function M.math.manhattan(x1, y1, x2, y2)
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end


--- math.vec2rad
-- @function luax.math.vec2rad
function M.math.vec2rad(x, y)
	return math.atan2(y, x)
end


--- table.get_item_from_array
-- @function luax.table.get_item_from_array
function M.table.get_item_from_array(array, key, value)
	for i = 1, #array do
		if array[i][key] == value then
			return array[i]
		end
	end

	return nil
end


--- table.contains
-- @function luax.table.contains
function M.table.contains(t, value)
	for i = 1, #t do
		if t[i] == value then
			return i
		end
	end
	return false
end


--- table.length
-- @function luax.table.length
function M.table.length(array)
	local length = 0
	for _ in pairs(array) do
		length = length + 1
	end
	return length
end


--- table.remove_item
-- @function luax.table.remove_item
function M.table.remove_item(t, value)
	local index = M.table.contains(t, value)
	if index then
		table.remove(t, index)
	end
end


--- table.remove_by_dict
-- @function luax.table.remove_by_dict
function M.table.remove_by_dict(t, example)
	local index = -1

	for i = 1, #t do
		local v = t[i]

		local is_match = true
		for key, val in pairs(example) do
			if v[key] ~= val then
				is_match = false
			end
		end

		if is_match then
			index = i
			break
		end
	end

	if index ~= -1 then
		table.remove(t, index)
		return true
	end

	return false
end


--- table.is_empty
-- @function luax.table.is_empty
function M.table.is_empty(t)
	if not t then
		return true
	end
	return next(t) == nil
end


--- table.extend
-- @function luax.table.extend
function M.table.extend(t1, t2)
	if not t2 then
		return t1
	end

	for k, v in pairs(t2) do
		t1[k] = v
	end

	return t1
end


-- for array
--- table.add
-- @function luax.table.add
function M.table.add(t1, t2)
	for i = 1, #t2 do
		table.insert(t1, t2[i])
	end
end


--- table.random
-- @function luax.table.random
function M.table.random(t)
	return t[math.random(#t)]
end


--- table.weight_random
-- @function luax.table.weight_random
function M.table.weight_random(chances, values)
	if values then
		assert(#values == #chances, "arrays should be with equals length")
	end

	local w = 0
	for i = 1, #chances do
		w = w + chances[i]
	end
	w = w * math.random()

	for i = 1, #chances do
		w = w - chances[i]
		if w <= 0 then
			if values then
				return values[i]
			else
				return i
			end
		end
	end

	if values then
		return values[#values]
	else
		return #chances
	end
end


--- table.shuffle
-- @function luax.table.shuffle
function M.table.shuffle(t, seed)
	if seed then
		math.randomseed(seed)
	end
	for _ = 1, 2 do
		for i = #t, 1, -1 do
			local j = math.random(i)
			t[i], t[j] = t[j], t[i]
		end
	end
	return t
end


--- table.copy array
-- @function luax.table.copy
function M.table.copy_array(orig)
	local result = {}

	for i = 1, #orig do
		table.insert(result, orig[i])
	end

	return result
end

--- table.deepcopy
-- @function luax.table.deepcopy
function M.table.deepcopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[M.table.deepcopy(orig_key)] = M.table.deepcopy(orig_value)
		end
		setmetatable(copy, M.table.deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end


--- table.override
-- @function luax.table.override
function M.table.override(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" and target[key] then
			M.table.override(value, target[key])
		else
			target[key] = value
		end
	end
end


--- table.list
-- @function luax.table.list
function M.table.list(t, field)
	local result = {}

	for key, value in pairs(t) do
		if field then
			table.insert(result, value[field])
		else
			table.insert(result, key)
		end
	end

	return result
end


--- table.tostring
-- @function luax.table.tostring
function M.table.tostring(t)
	local result = ""

	if t and M.table.length(t) ~= 0 then
		for k, v in pairs(t) do
			if type(v) == "table" then
				v = M.table.tostring(v)
			end
			result = string.format("%s = %s %s", k, v, result)
		end
		result = string.format("{ %s}", result)
	end

	return result
end


--- string.split
-- @function luax.string.split
function M.string.split(inputstr, sep)
	sep = sep or "%s"
	local t = {}
	local i = 1
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end


--- string.add_prefix_zeros
-- @function luax.string.add_prefix_zeros
function M.string.add_prefix_zeros(str, count)
	for _ = string.len(str), count - 1 do
		str = "0" .. str
	end
	return str
end


--- string.split_by_rank
-- @function luax.string.split_by_rank
function M.string.split_by_rank(str)
	str = tostring(str)
	local new_s = ""

	local cur_index = str:len()
	while cur_index >= 3 do
		new_s = str:sub(cur_index - 2, cur_index) .. " " .. new_s
		cur_index = cur_index - 3
	end
	if cur_index > 0 then
		new_s = str:sub(1, cur_index) .. " " .. new_s
	end

	return new_s
end


--- string.starts
-- @function luax.string.starts
function M.string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end


--- string.ends
-- @function luax.string.ends
function M.string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end


--- string.random
-- @function luax.string.random
function M.string.random(length)
	local result = ""

	for i = 1, length do
		result = result .. string.char(math.random(97, 122))
	end

	return result
end


--- go.set_alpha
-- @function luax.go.set_alpha
function M.go.set_alpha(sprite_id, alpha)
	go.set(sprite_id, "tint.w", alpha)
end


--- gui.set_alpha
-- @function luax.gui.set_alpha
function M.gui.set_alpha(node, alpha)
	local color = gui.get_color(node)
	color.w = alpha
	gui.set_color(node, color)
end


--- gui.get_alpha
-- @function luax.gui.get_alpha
function M.gui.get_alpha(node, alpha)
	return gui.get_color(node).w
end


--- debug.timelog
-- @function luax.debug.timelog
function M.debug.timelog(name)
	if not debug._timelog_time then
		debug._timelog_time = socket.gettime()
		return
	end
	print("[Timelog]:", name, "time:", socket.gettime() - debug._timelog_time)
	debug._timelog_time = socket.gettime()
end


--- gui.is_chain_enabled
-- @function luax.gui.is_chain_enabled
function M.gui.is_chain_enabled(node)
	local current = node
	while current do
		if not gui.is_enabled(current) then
			return false
		end
		current = gui.get_parent(current)
	end

	return true
end


--- vmath.rad2vec
-- @function luax.vmath.rad2vec
function M.vmath.rad2vec(radians)
	local dir_vector = vmath.vector3()
	dir_vector.x = math.cos(radians)
	dir_vector.y = math.sin(radians)
	return dir_vector
end


--- vmath.vec2rad
-- @function luax.vmath.vec2rad
function M.vmath.vec2rad(vector)
	return math.atan2(vector.y, vector.x)
end


--- vmath.rad2quat
-- @function luax.vmath.rad2quat
function M.vmath.rad2quat(radians)
	return vmath.quat_rotation_z(radians)
end


--- vmath.vec2quat
-- @function luax.vmath.vec2quat
function M.vmath.vec2quat(vector)
	local dir = vmath.normalize(vector)
	dir.z = 0
	return vmath.rad2quat(vmath.vec2rad(dir))
end


--- vmath.distance
-- @function luax.vmath.distance
function M.vmath.distance(v1, v2)
	return math.sqrt((v2.x - v1.x)^2 + (v2.y - v1.y)^2)
end


return M
