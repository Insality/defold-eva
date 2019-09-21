local M = {
	go = {},
	gui = {},
	string = {},
	math = {},
	table = {},
	vmath = {},
	debug = {},
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


function M.math.step(current, target, step)
	if current < target then
		return math.min(current + step, target)
	else
		return math.max(target, current - step)
	end
end


function M.math.sign(value)
	if value > 0 then
		return 1
	elseif value < 0 then
		return -1
	else
		return 0
	end
end


function M.math.lerp(a, b, t)
	return a + (b - a) * t
end


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


function M.math.round(num, numDecimalPlaces)
	local mult = 10 ^ (numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


function M.math.is(value, ...)
	for i = 1, select("#", ...) do
		if value == select(i, ...) then
			return true
		end
	end
	return false
end


function M.math.chance(percent)
	return math.random(1, 100) <= (percent * 100)
end


function M.math.distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end


function M.math.manhattan(x1, y1, x2, y2)
	return math.abs(x2 - x1) + math.abs(y2 - y1)
end


function M.math.vec2rad(x, y)
	return math.atan2(y, x)
end


function M.table.get_item_from_array(array, key, value)
	for i = 1, #array do
		if array[i][key] == value then
			return array[i]
		end
	end

	return {}
end


function M.table.contains(t, value)
	for i = 1, #t do
		if t[i] == value then
			return i
		end
	end
	return false
end


function M.table.length(array)
	local length = 0
	for _ in pairs(array) do
		length = length + 1
	end
	return length
end


function M.table.remove_item(t, value)
	local index = table.contains(t, value)
	if index then
		table.remove(t, index)
	end
end


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
	end
end


function M.table.is_empty(t)
	if not t then
		return true
	end
	return next(t) == nil
end


function M.table.extend(t1, t2)
	for k, v in pairs(t2) do
		t1[k] = v
	end
end


-- for array
function M.table.add(t1, t2)
	for i = 1, #t2 do
		table.insert(t1, t2[i])
	end
end


function M.table.random(t)
	return t[math.random(#t)]
end


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


function M.table.deepcopy(orig)
	local copy
	if type(orig) == "table" then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
		end
		setmetatable(copy, table.deepcopy(getmetatable(orig)))
	else
		copy = orig
	end
	return copy
end


function M.table.override(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" and target[key] then
			M.table.override(value, target[key])
		else
			target[key] = value
		end
	end
end


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


function M.string.add_prefix_zeros(str, count)
	for _ = string.len(str), count - 1 do
		str = "0" .. str
	end
	return str
end


function M.string.split_by_rank(str)
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


function M.string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end


function M.string.ends(String,End)
	return End=='' or string.sub(String,-string.len(End))==End
end


function M.string.random(length)
	local result = ""

	for i = 1, length do
		result = result .. string.char(math.random(97, 122))
	end

	return result
end


function M.gui.get_full_position(node)
	local p = gui.get_position(node)
	local par = gui.get_parent(node)
	while par do
		local pos = gui.get_position(par)

		local s = gui.get_scale(par)
		p.x = p.x * s.x
		p.y = p.y * s.y

		p = p + pos
		par = gui.get_parent(par)
	end
	return p
end


function M.gui.set_alpha(node, alpha)
	local color = gui.get_color(node)
	color.w = alpha
	gui.set_color(node, color)
end


function M.gui.get_alpha(node, alpha)
	return gui.get_color(node).w
end


function M.go.get_full_position(node)
	local p = go.get_position(node)
	local par = go.get_parent(node)
	while par do
		p = p + go.get_position(par)
		par = go.get_parent(par)
	end
	return p
end


function M.debug.timelog(name)
	if not debug._timelog_time then
		debug._timelog_time = socket.gettime()
		return
	end
	print("[Timelog]:", name, "time:", socket.gettime() - debug._timelog_time)
	debug._timelog_time = socket.gettime()
end


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


function M.vmath.rad2vec(radians)
	local dir_vector = vmath.vector3()
	dir_vector.x = math.cos(radians)
	dir_vector.y = math.sin(radians)
	return dir_vector
end


function M.vmath.vec2rad(vector)
	return math.atan2(vector.y, vector.x)
end


function M.vmath.rad2quat(radians)
	return vmath.quat_rotation_z(radians)
end


function M.vmath.vec2quat(vector)
	local dir = vmath.normalize(vector)
	dir.z = 0
	return vmath.rad2quat(vmath.vec2rad(dir))
end


function M.vmath.distance(v1, v2)
	return math.sqrt((v2.x - v1.x)^2 + (v2.y - v1.y)^2)
end


return M
