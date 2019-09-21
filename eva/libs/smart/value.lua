local const = require("eva.const")
local broadcast = require("eva.libs.broadcast")

local M = {}


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

	local old_value = self.data_table.amount
	local delta = value - old_value

	if delta < 0 and self:is_max() and self.restore then
		self.data_table.last_restore_time = M.get_time()
	end

	self.data_table.amount = value

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
	return self.data_table.amount
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


function M.get_visual(self)
	return self:get() - self.visual_credit
end


function M.get_seconds_to_restore(self)
	local last = self.data_table.last_restore_time
	local skipped = M.get_time() - last

	return math.max(0, self.restore.timer - skipped)
end


local function update_timer(self)
	local cur_time = M.get_time()
	self.data_table.last_restore_time = math.min(self.data_table.last_restore_time, cur_time)

	local elapsed = cur_time - self.data_table.last_restore_time
	if elapsed >= self.restore.timer then
		local restore_value = self.restore.value or 1
		local amount = math.floor(elapsed / self.restore.timer)

		local need_to_add = amount * restore_value
		if self.restore.max then
			need_to_add = math.min(need_to_add, self.restore.max)
		end
		self:add(need_to_add)

		local cur_elapse_time = elapsed - (amount * self.restore.timer)
		self.data_table.last_restore_time = cur_time - cur_elapse_time
	end
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

	if self.data_table.infinity_time_end > 0 then
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


function M.init(self, params, data_table)
	self.data_table = data_table
	self.params = params or {}

	if self.params.restore and self.params.restore.timer then
		self.restore = self.params.restore
		self.params.restore = nil
	end

	if self.params.default then
		self.data_table.amount = self.params.default
	end
	self:set(self.data_table.amount or 0)

	self:sync_visual()
end


function M.add_infinity_time(self, seconds)
	if self.data_table.infinity_time_end == 0 then
		self.data_table.infinity_time_end = M.get_time() + seconds
	else
		self.data_table.infinity_time_end = self.data_table.infinity_time_end + seconds
	end
end


function M.is_infinity(self)
	return self.data_table.infinity_time_end > 0
end


function M.get_infinity_seconds(self)
	local infinity_time = math.max(0, self.data_table.infinity_time_end - M.get_time())
	return math.ceil(infinity_time)
end


function M.update(self)
	if self.restore and self.restore.timer then
		update_timer(self)
	end

	if self.data_table.infinity_time_end < M.get_time() then
		self.data_table.infinity_time_end = 0
	end
end


return M
