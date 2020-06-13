local M = {}


function M.set(self, value, reason)
	if self.params.min then
		value = math.max(self.params.min, value)
	end

	if self.params.max then
		value = math.min(value, self.params.max)
	end

	local old_value = self:get()
	local delta = value - old_value

	self.data_table.amount = value - self.data_table.offset

	if delta ~= 0 then
		if self._on_change_callbacks then
			for i = 1, #self._on_change_callbacks do
				self._on_change_callbacks[i](self, delta, reason)
			end
		end
	end

	return delta
end


function M.get(self)
	return self.data_table.amount + self.data_table.offset
end


function M.add(self, value, reason, is_visual_later)
	local delta = self:set(self:get() + value, reason)
	if is_visual_later then
		self.visual_credit = self.visual_credit + delta
	end

	return self:get()
end


function M.sync_visual(self)
	local prev_value = self.visual_credit
	self.visual_credit = 0

	return prev_value
end


function M.add_visual(self, value)
	self.visual_credit = self.visual_credit - value
end


function M.get_visual(self)
	return self:get() - self.visual_credit
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

	if self:check(value) then
		return self:add(-value, reason)
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

	if not data_table.amount then
		data_table.amount = (self.params.default or 0) - self.data_table.offset
	end
	self:set(data_table.amount)
	self:sync_visual()
end


--- Offset needed for protect from memory scanning
-- Call random offset on window.focus for more protecting
function M.random_offset(self)
	local prev_offset = self.data_table.offset
	self.data_table.offset = math.random(99, 9999)
	local diff = prev_offset - self.data_table.offset
	self.data_table.amount = self.data_table.amount + diff
end


--- Reset offset to 0 value. This will turn off
-- memory protecting with value offsets
function M.reset_offset(self)
	local prev_offset = self.data_table.offset
	self.data_table.offset = 0
	local diff = prev_offset
	self.data_table.amount = self.data_table.amount + diff
end


--- Return token_id from token.params.name
function M.get_token_id(self)
	return self.params.name
end


return M
