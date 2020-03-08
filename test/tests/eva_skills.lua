local eva = require("eva.eva")
local mock = require("deftest.mock.mock")
local mock_time = require("deftest.mock.time")
local const = require("eva.const")

local USE = const.EVENT.SKILL_USE
local USE_END = const.EVENT.SKILL_USE_END
local COOLDOWN_START = const.EVENT.SKILL_COOLDOWN_START
local COOLDOWN_END = const.EVENT.SKILL_COOLDOWN_END

local events = {
	[USE] = function() end,
	[USE_END] = function() end,
	[COOLDOWN_START] = function() end,
	[COOLDOWN_END] = function() end,
}

local test_config = {
	Skills = {
		skills = {
			shoot = { cooldown = 5 },
			war_cry = { duration = 30, cooldown = 1 },
			teleport = { cooldown = 5, max_stack = 3, restore_amount = 1 },
			teleport_fast = { cooldown = 3, max_stack = 6, restore_amount = 2 },
			pyroblast = { cast_time = 5, cooldown = 60 },
			smash = {}
		}
	}
}

local function set_time(time)
	mock_time.set(time)
	eva.update(1)
	return time
end

return function()
	describe("Eva skills", function()
		local CONTAINER = "player"

		before(function()
			eva.init("/resources/tests/eva_tests.json", {
				db_settings = test_config
			})

			mock.mock(events)
			mock_time.mock()

			eva.events.subscribe_map(events)
			set_time(0)
		end)

		after(function()
			mock_time.unmock()
			mock.unmock(events)
		end)

		it("Should have default correct values and api", function()
			assert_equal(events[USE].calls, 0)
			assert_equal(events[USE_END].calls, 0)
			assert_equal(events[COOLDOWN_START].calls, 0)
			assert_equal(events[COOLDOWN_END].calls, 0)

			assert_true(eva.skill.is_can_use(CONTAINER, "shoot"))
			assert_true(eva.skill.is_full_stack(CONTAINER, "shoot"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "shoot"), 1)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 3)
			assert_false(eva.skill.is_active(CONTAINER, "shoot"))
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "shoot"))
		end)

		it("Should have correct cooldown", function()
			eva.skill.use(CONTAINER, "shoot")
			assert_false(eva.skill.is_can_use(CONTAINER, "shoot"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "shoot"), 0)
			assert_false(eva.skill.is_active(CONTAINER, "shoot"))
			assert_true(eva.skill.is_on_cooldown(CONTAINER, "shoot"))
			assert_equal(events[USE].calls, 1)
			assert_equal(events[COOLDOWN_START].calls, 1)

			set_time(1)
			assert_equal(eva.skill.get_cooldown_time("shoot"), 5)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "shoot"), 4)

			set_time(4)
			assert_true(eva.skill.is_on_cooldown(CONTAINER, "shoot"))
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "shoot"), 1)

			set_time(5)
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "shoot"))
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "shoot"), 0)
			assert_equal(eva.skill.get_cooldown_progress(CONTAINER, "shoot"), 1)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "shoot"), 1)
			assert_true(eva.skill.is_full_stack(CONTAINER, "shoot"))
			assert_equal(events[COOLDOWN_START].calls, 1)
			assert_equal(events[COOLDOWN_END].calls, 1)
		end)

		it("Should have correct cooldown with stack", function()
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "teleport"))
			assert_true(eva.skill.is_full_stack(CONTAINER, "teleport"))

			eva.skill.use(CONTAINER, "teleport")
			assert_equal(eva.skill.get_cooldown_time("teleport"), 5)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport"), 5)
			assert_equal(eva.skill.get_cooldown_progress(CONTAINER, "teleport"), 0)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 2)

			set_time(1)
			eva.skill.use(CONTAINER, "teleport")
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport"), 4)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 1)

			set_time(2)
			eva.skill.use(CONTAINER, "teleport")
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport"), 3)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 0)

			set_time(7)
			eva.skill.use(CONTAINER, "teleport")
			assert_true(eva.skill.is_empty_stack(CONTAINER, "teleport"))
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport"), 3)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 0)

			set_time(10)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport"), 1)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport"), 5)

			set_time(20)
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "teleport"))
			assert_true(eva.skill.is_full_stack(CONTAINER, "teleport"))
		end)

		it("Should have usage with no params", function()
			assert_true(eva.skill.is_can_use(CONTAINER, "smash"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "smash"), 1)

			eva.skill.use(CONTAINER, "smash")
			eva.skill.use(CONTAINER, "smash")
			eva.skill.use(CONTAINER, "smash")

			assert_true(eva.skill.is_can_use(CONTAINER, "smash"))
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "smash"))
			assert_equal(events[USE].calls, 3)
		end)

		it("Should have different restore amount", function()
			eva.skill.use(CONTAINER, "teleport_fast")
			assert_equal(eva.skill.get_cooldown_time("teleport_fast"), 3)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport_fast"), 3)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport_fast"), 5)
			assert_true(eva.skill.is_on_cooldown(CONTAINER, "teleport_fast"))

			set_time(1)
			eva.skill.use(CONTAINER, "teleport_fast")
			eva.skill.use(CONTAINER, "teleport_fast")
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "teleport_fast"), 2)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport_fast"), 3)

			set_time(3)
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "teleport_fast"), 5)
		end)

		it("Should have no cooldown, while active", function()
			eva.skill.use(CONTAINER, "war_cry")
			assert_true(eva.skill.is_active(CONTAINER, "war_cry"))
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "war_cry"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "war_cry"), 0)
			assert_equal(eva.skill.get_cooldown_progress(CONTAINER, "war_cry"), 1)
			assert_equal(eva.skill.get_cooldown_time("war_cry"), 1)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "war_cry"), 0)
			assert_false(eva.skill.is_can_use(CONTAINER, "war_cry"))

			set_time(15)
			assert_true(eva.skill.is_active(CONTAINER, "war_cry"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "war_cry"), 0)
			assert_equal(eva.skill.get_cooldown_progress(CONTAINER, "war_cry"), 1)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "war_cry"), 0)
			assert_false(eva.skill.is_can_use(CONTAINER, "war_cry"))

			set_time(30)
			assert_false(eva.skill.is_active(CONTAINER, "war_cry"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "war_cry"), 0)
			assert_true(eva.skill.is_on_cooldown(CONTAINER, "war_cry"))
			assert_equal(eva.skill.get_cooldown_progress(CONTAINER, "war_cry"), 0)
			assert_equal(eva.skill.get_cooldown_time_left(CONTAINER, "war_cry"), 1)
			assert_false(eva.skill.is_can_use(CONTAINER, "war_cry"))

			set_time(31)
			assert_false(eva.skill.is_active(CONTAINER, "war_cry"))
			assert_equal(eva.skill.get_stack_amount(CONTAINER, "war_cry"), 1)
			assert_false(eva.skill.is_on_cooldown(CONTAINER, "war_cry"))
			assert_true(eva.skill.is_can_use(CONTAINER, "war_cry"))
		end)

		it("Should correct restore all skills", function()
		end)

		it("Should have cast time", function()
		end)

		it("Should have correct end use of channeling or duration skill", function()
		end)

		it("Should have correct work of channel type", function()
		end)

		it("Should have correct work of complex params", function()
		end)

		it("Should have ability to skip cooldown time", function()
		end)

		it("Should correct interupt usage skill", function()
		end)
	end)
end