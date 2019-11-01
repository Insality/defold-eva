local mock_time = require("deftest.mock.time")
local eva = require("eva.eva")

return function()
	describe("Eva Daily", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
			mock_time.mock()
			mock_time.set(5000)
		end)

		after(function()
			mock_time.unmock()
		end)

		it("Should be inactive at start", function()
			assert(eva.daily.is_active() == false)

			eva.daily.set_active(true)

			assert(eva.daily.is_active() == true)
		end)


		it("Should give actual reward", function()
			assert(eva.token.get("money") == 0)

			eva.daily.set_active(true)
			eva.daily.pick()

			assert(eva.daily.get_time() == 10)
			assert(eva.daily.get_wait_time() == 30)
			assert(eva.token.get("money") == 1000)

			eva.daily.pick()
			assert(eva.token.get("money") == 1000)
		end)


		it("Should get valid time", function()
			eva.daily.set_active(true)
			assert(eva.daily.get_time() == 0)
			assert(eva.daily.get_wait_time() == 0)
		end)

		it("Should reset if no pick prize", function()
			eva.daily.set_active(true)
			assert(eva.daily.get_wait_time() == 0)
			eva.daily.pick()
			assert(eva.daily.get_wait_time() == 30)
			local state = eva.daily.get_current_state()
			assert(state[1] == true)

			mock_time.elapse(30)
			eva.daily.on_eva_second()
			local new_state = eva.daily.get_current_state()
			assert(#new_state == 0)
		end)

		it("Should work on wait mode", function()
			eva.init("/resources/tests/eva_tests_daily_wait.json")
			eva.daily.set_active(true)
			eva.daily.pick()

			mock_time.elapse(30)
			eva.daily.on_eva_second()
			local state1 = eva.daily.get_current_state()
			assert(#state1 == 1)

			mock_time.elapse(100)
			eva.daily.on_eva_second()

			assert(eva.daily.get_time() == 0)
			assert(eva.daily.get_wait_time() == 0)

			local state2 = eva.daily.get_current_state()
			assert(#state2 == 1)

			eva.daily.pick()
			local state3 = eva.daily.get_current_state()
			assert(#state3 == 2)
		end)

		it("Should work on skip mode", function()
			eva.init("/resources/tests/eva_tests_daily_skip.json")
			eva.daily.set_active(true)
			eva.daily.pick()

			mock_time.elapse(10)
			eva.daily.on_eva_second()
			local state1 = eva.daily.get_current_state()
			assert(#state1 == 1)

			mock_time.elapse(20)
			eva.daily.on_eva_second()

			assert(eva.daily.get_time() == 10)
			assert(eva.daily.get_wait_time() == 30)

			local state2 = eva.daily.get_current_state()
			assert(#state2 == 2)
			assert(state2[1] == true)
			assert(state2[2] == false)

			-- check time is can translate to next pickup

			mock_time.elapse(35)
			eva.daily.on_eva_second()

			assert(eva.daily.get_time() == 5)
			assert(eva.daily.get_wait_time() == 25)
			eva.daily.pick()

			mock_time.elapse(25)
			eva.daily.on_eva_second()

			-- new cycle
			local state3 = eva.daily.get_current_state()
			assert(#state3 == 0)
			assert(eva.daily.get_time() == 0)
			assert(eva.daily.get_wait_time() == 0)
			eva.daily.pick()

			mock_time.elapse(4000)
			eva.daily.on_eva_second()

			local state4 = eva.daily.get_current_state()
			assert(#state4 == 2)
			assert(state4[1] == true)
			assert(state4[2] == false)
			-- We skip time to next prize, but not to much, left wait time full
			assert(eva.daily.get_time() == 0)
			assert(eva.daily.get_wait_time() == 20)
		end)

		it("Should make cycle of rewards", function()
			eva.daily.set_active(true)
			eva.daily.pick()

			mock_time.elapse(10)
			eva.daily.on_eva_second()
			eva.daily.pick()

			local state = eva.daily.get_current_state()
			assert(#state == 2)

			mock_time.elapse(10)
			eva.daily.on_eva_second()
			eva.daily.pick()

			assert(eva.token.get("money") == 2000)
			assert(eva.token.get("energy") == 50)

			local state2 = eva.daily.get_current_state()
			assert(#state2 == 0)

			assert(eva.daily.get_time() == 10)
		end)
	end)
end