local eva = require("eva.eva")
local mock = require("deftest.mock.mock")

return function()
	describe("Eva callbacks", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		it("Callback create", function()
			local fn = function() end

			local callback = eva.callbacks.create(fn)

			assert(type(callback) == "number")

			local callback2 = eva.callbacks.create(fn)
			assert(callback ~= callback2)
		end)

		it("Should correct call callbacks", function()
			local data = {
				fn = function() return 10 end
			}
			mock.mock(data)
			local callback = eva.callbacks.create(data.fn)

			local result = eva.callbacks.call(callback)
			assert(result == 10)
			assert(data.fn.calls == 1)

			local result2 = eva.callbacks.call(callback)
			assert(result2 == 10)
			assert(data.fn.calls == 2)

			eva.callbacks.clear(callback)
			
			local another_result = eva.callbacks.call(callback)
			assert(not another_result)
			assert(data.fn.calls == 2)
		end)

		it("Should correct clear callbacks", function()
			local data = {
				fn = function() return 10 end
			}
			mock.mock(data)
			local callback = eva.callbacks.create(data.fn)

			local result = eva.callbacks.clear(callback)
			assert(result)
			assert(data.fn.calls == 0)

			local another_result = eva.callbacks.clear(callback)
			assert(not another_result)
			assert(data.fn.calls == 0)
		end)
	end)
end
