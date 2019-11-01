return function()
	local time_string = require("eva.libs.time_string")

	describe("Time string library", function()
		it("Test delta time", function()
			local date = time_string.parse_ISO("2019-09-10Z")

			local cur_time = time_string.parse_ISO("2019-10-10T23:10:00Z")
			local next_time = time_string.get_next_time(date, "1Y", cur_time)
			assert(time_string.get_ISO(next_time) == "2020-09-10T00:00:00Z")

			next_time = time_string.get_next_time(date, "10D", cur_time)
			assert(time_string.get_ISO(next_time) == "2019-10-20T00:00:00Z")

			local next_date = time_string.parse_ISO("2019-11-10Z")
			next_time = time_string.get_next_time(next_date, "2Y", cur_time)
			assert(time_string.get_ISO(next_time) == "2019-11-10T00:00:00Z")


			local sunday = time_string.parse_ISO("2017-10-01Z")
			next_time = time_string.get_next_time(sunday, "1W", cur_time)
			assert(time_string.get_ISO(next_time) == "2019-10-13T00:00:00Z")
		end)

		it("Test delta to seconds", function()
			assert(time_string.get_delta_seconds("1W") == 60 * 60 * 24 * 7)
			assert(time_string.get_delta_seconds("1D") == 60 * 60 * 24)
			assert(time_string.get_delta_seconds("10m") == 60 * 10)
		end)
	end)
end