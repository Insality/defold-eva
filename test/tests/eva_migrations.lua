local eva = require("eva.eva")
local app = require("eva.app")
local const = require("eva.const")
local mock = require("deftest.mock.mock")

return function()
	describe("Eva migrations", function()
		after(function()
			eva.saver.delete()
		end)

		it("It should not apply migrations to new profile", function()
			eva.saver.delete("eva_test.json")

			local funcs = {
				first = function() end,
				second = function() end
			}
			mock.mock(funcs)

			local migrations = {funcs.first, funcs.second}

			eva.init("/resources/tests/eva_tests.json", {
				migrations = migrations
			})

			assert(funcs.first.calls == 0)
			assert(funcs.second.calls == 0)
			assert(app[const.EVA.SAVER].migration_version == 2)
		end)

		it("It should apply migrations", function()
			eva.init("/resources/tests/eva_tests.json")

			local funcs = {
				first = function() end,
				second = function() end,
				third = function() end,
				fourt = function() end,
			}
			mock.mock(funcs)

			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json", {
				migrations = {funcs.first, funcs.second}
			})

			assert(funcs.first.calls == 1)
			assert(funcs.second.calls == 1)
			assert(funcs.third.calls == 0)
			assert(funcs.fourt.calls == 0)
			assert(app[const.EVA.SAVER].migration_version == 2)

			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json", {
				migrations = {funcs.first, funcs.second, funcs.third, funcs.fourt}
			})

			assert(funcs.first.calls == 1)
			assert(funcs.second.calls == 1)
			assert(funcs.third.calls == 1)
			assert(funcs.fourt.calls == 1)

			assert(app[const.EVA.SAVER].migration_version == 4)
		end)
	end)
end