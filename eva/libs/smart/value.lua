local log = require("eva.log")
local const = require("eva.const")
local broadcast = require("eva.libs.broadcast")

local logger = log.get_logger()

local M = {}
M.__is_smart_value__ = true


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
		self.restore.last_restore_time = M.get_time()
	end

	self._value = value

	if delta ~= 0 then
		if self._on_change_callbacks then
			for i = 1, #self._on_change_callbacks do
				self._on_change_callbacks[i](delta, reason, self.params.name, value)
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
	broadcast.send(const.MSG.SMART_VISUAL_UPDATE, {value = value, delta = value, name = self.params.name})
end


function M.get_visual(self, value)
	return self:get() - self.visual_credit
end


function M.get_seconds_to_restore(self)
	local last = self.restore.last_restore_time
	local skipped = M.get_time() - last

	return math.max(0, self.restore.timer - skipped)
end


local function update_timer(self)
	local cur_time = M.get_time()
	self.restore.last_restore_time = math.min(self.restore.last_restore_time, cur_time)

	local elapsed = cur_time - self.restore.last_restore_time
	if elapsed >= self.restore.timer then
		local restore_value = self.restore.value or 1
		local amount = math.floor(elapsed / self.restore.timer)

		local need_to_add = amount * restore_value
		if self.restore.max then
			need_to_add = math.min(need_to_add, self.restore.max)
		end
		self:add(need_to_add)

		local cur_elapse_time = elapsed - (amount * self.restore.timer)
		self.restore.last_restore_time = cur_time - cur_elapse_time
	end
end


function M.save(self)
	local save_field = {
		value = self:get()
	}

	if self.restore then
		save_field.last_restore_time = self.restore.last_restore_time
	end

	if self.infinity_time_end then
		save_field.infinity_time_end = self.infinity_time_end
	end

	return save_field
end


function M.load(self, data)
	if not data then
		return
	end

	data.value = data.value or self.params.default
	self:set(data.value)

	if data.last_restore_time and self.restore then
		self.restore.last_restore_time = data.last_restore_time
	end

	self.infinity_time_end = data.infinity_time_end
	self:sync_visual()
	self:update()
end


function M.is_max(self)
	if self.params.max then
		return self:get() == self.params.max
	end
	return false
end


function M.is_any(self)
	return self:get() > 0
end


function M.is_empty(self)
	return self:get() == 0
end


function M.check(self, value)
	return self:get() >= value
end


function M.pay(self, value, reason)
	value = value or 1

	if self.infinity_time_end then
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


function M.init(self, params)
	self.params = params or {}

	if self.params.restore and self.params.restore.timer then
		self.restore = self.params.restore
		self.restore.last_restore_time = self.restore.last_restore_time or 0
		self.params.restore = nil
	end

	self._value = self.params.default or 0
	self.infinity_time_end = nil
	self:set(self._value)
	self:sync_visual()
end


function M.add_infinity_time(self, seconds)
	if not self.infinity_time_end then
		self.infinity_time_end = M.get_time() + seconds
	else
		self.infinity_time_end = self.infinity_time_end + seconds
	end
end


function M.is_infinity(self)
	return self.infinity_time_end
end


function M.get_infinity_seconds(self)
	local infinity_time = math.max(0, self.infinity_time_end - M.get_time())
	return math.ceil(infinity_time)
end


function M.update(self)
	if self.restore and self.restore.timer then
		update_timer(self)
	end

	if self.infinity_time_end and self.infinity_time_end < M.get_time() then
		self.infinity_time_end = nil
	end
end


return M
