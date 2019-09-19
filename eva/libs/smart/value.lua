local const = require("eva.const")
local broadcast = require("eva.libs.broadcast")

local M = {}
M.is_smart_value = true

function M.get_time()
	return socket.gettime()
end

function M.set(self, value, reason)
	if self.params.min then
		value = math.max(self.params.min, value)
	end
	if self.params.max then
		value = math.min(value, self.params.max)
	end
	local old_value = self._value
	local delta = value - old_value

	if delta < 0 and self:is_max() and self.restore then
		self.restore.last_time = M.get_time()
	end

	self._value = value

	if delta ~= 0 then
		print("Change", self.params.name, "from", old_value, "to", value)
		broadcast.send(const.MSG.SMART_VALUE_UPDATE {value = value, delta = delta, name = self.params.name, reason = reason})
		if self._on_change_callbacks then
			for i = 1, #self._on_change_callbacks do
				self._on_change_callbacks[i](delta, reason)
			end
		end
	end

	return delta
end

function M.get(self)
	return self._value
end

function M.add(self, value, reason, is_visual_later)
	local delta = self:set(self:get() + value, reason)
	if is_visual_later then
		self.visual_credit = self.visual_credit + delta
	end
	return delta
end


function M.sync_visual(self)
	self.visual_credit = 0
end

function M.add_visual(self, value)
	self.visual_credit = self.visual_credit - value
	broadcast.send("visual_changed", {value = value, delta = value, name = self.params.name})
end

function M.get_visual(self, value)
	return self:get() - self.visual_credit
end


function M.get_seconds_to_restore(self)
	local last = self.restore.last_time
	local skipped = M.get_time() - last
	return math.max(0, self.restore.timer - skipped)
end

local function update_timer(self, cur_time)
	cur_time = cur_time or M.get_time()
	self.restore.last_time = math.min(self.restore.last_time, cur_time)

	local elapsed = cur_time - self.restore.last_time
	if elapsed >= self.restore.timer then
		local restore_value = self.restore.r_value or 1
		local amount = math.floor(elapsed / self.restore.timer)

		local need_to_add = amount * restore_value
		if self.restore.r_max then
			need_to_add = math.min(need_to_add, self.	restore.r_max)
		end
		self:add(need_to_add)

		local cur_elapsed_timer = elapsed - (amount * self.restore.timer)
		self.restore.last_time = cur_time - cur_elapsed_timer
	end
end


function M.save(self)
	local save_field = {
		value = self:get()
	}
	if self.restore then
		save_field.last_time = self.restore.last_time
	end
	if self.inf_timer then
		save_field.inf_timer = self.inf_timer
	end
	return save_field
end

function M.load(self, data)
	if not data then
		return
	end

	data.value = data.value or self.params.default
	self:set(data.value)
	if data.last_time and self.restore then
		self.restore.last_time = data.last_time
	end
	self.inf_timer = data.inf_timer
	self:sync_visual()
	self:update()
end


-- Utils
function M.is_max(self)
	if self.params.max then
		return self:get() == self.params.max
	end
	return false
end

function M.any(self)
	return self:get() > 0
end

function M.empty(self)
	return self:get() == 0
end

function M.check(self, value)
	return self:get() >= value
end

function M.pay(self, value, reason)
	value = value or 1
	if self.inf_timer then
		return true
	end
	if self:check(value) then
		self:add(-value, reason)
		return true
	end
	return false
end

function M.set_max(self)
	if self.params.max then
		self:set(self.params.max)
	end
end

function M.on_change(self, callback)
	self._on_change_callbacks = self._on_change_callbacks or {}
	table.insert(self._on_change_callbacks, callback)
end
-- end utils

function M.init(self, params)
	self.params = params or {}

	if self.params.restore and self.params.restore.timer then
		self.restore = self.params.restore
		self.restore.last_time = self.restore.last_time or 0
		self.params.restore = nil
	end

	self._value = self.params.default or 0
	self.inf_timer = nil
	self:set(self._value)
	self:sync_visual()
end


function M.add_inf_timer(self, seconds)
	if not self.inf_timer then
		self.inf_timer = M.get_time() + seconds
	else
		self.inf_timer = self.inf_timer + seconds
	end
end


function M.is_inf(self)
	return self.inf_timer
end


function M.get_inf_seconds(self)
	return math.max(0, self.inf_timer - M.get_time())
end


-- cur_time in seconds
function M.update(self, cur_time)
	if self.restore and self.restore.timer then
		update_timer(self, cur_time)
	end
	if self.inf_timer and self.inf_timer < M.get_time() then
		self.inf_timer = nil
	end
end

return M