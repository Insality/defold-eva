local mock_time = require("deftest.mock.time")
local eva = require("eva.eva")

return function()
	describe("Eva Timers", function()
		local id = "test.id"
		local data = "data string"
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock_time.mock()
			mock_time.set(0)
		end)

		after(function()
			mock_time.unmock()
		end)

		it("Should be creatable", function()
			assert(eva.timers.get(id) == nil)
			eva.timers.add(id, data, 100)
			assert(eva.timers.get(id) ~= nil)
		end)


		it("Check basic timer api", function()
			eva.timers.add(id, data, 50)
			assert(eva.timers.get_time(id) == 50)

			mock_time.elapse(10)
			assert(eva.timers.get_time(id) == 40)

			assert(not eva.timers.is_end(id))
			mock_time.elapse(40)
			assert(eva.timers.is_end(id))

			assert(eva.timers.get(id) ~= nil)
			eva.timers.clear(id)
			assert(eva.timers.get(id) == nil)
			assert(eva.timers.get_time(id) < 0)
		end)

		it("Should be pausable", function()
			eva.timers.add(id, data, 50)
			eva.timers.set_pause(id, true)
			mock_time.elapse(10)
			assert(eva.timers.get_time(id) == 50)
			mock_time.elapse(10)
			eva.timers.set_pause(id, false)
			assert(eva.timers.get_time(id) == 50)
			mock_time.elapse(20)
			assert(eva.timers.get_time(id) == 30)
		end)
	end)
end