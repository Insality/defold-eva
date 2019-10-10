local iso_format = require("eva.libs.iso_format")

return function()
	describe("Iso parser", function()
		it("Test delta time", function()
			local date = "2019-09-10Z"

			local cur_time = "2019-10-10T23:10:00Z"
			local next_time = iso_format.get_time_to_next(date, "1Y", cur_time)
			assert(iso_format.get_time(next_time) == "2020-09-10T00:00:00Z")

			next_time = iso_format.get_time_to_next(date, "10D", cur_time)
			assert(iso_format.get_time(next_time) == "2019-10-20T00:00:00Z")

			local next_date = "2019-11-10Z"
			next_time = iso_format.get_time_to_next(next_date, "2Y", cur_time)
			assert(iso_format.get_time(next_time) == "2019-11-10T00:00:00Z")


			local sunday = "2017-10-01Z"
			next_time = iso_format.get_time_to_next(sunday, "1W", cur_time)
			assert(iso_format.get_time(next_time) == "2019-10-13T00:00:00Z")
		end)

		it("Test delta to seconds", function()
			assert(iso_format.get_delta_seconds("1W") == 60 * 60 * 24 * 7)
			assert(iso_format.get_delta_seconds("1D") == 60 * 60 * 24)
			assert(iso_format.get_delta_seconds("10m") == 60 * 10)
		end)
	end)
end