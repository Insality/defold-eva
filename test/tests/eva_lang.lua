local eva = require("eva.eva")

return function()
	describe("Eva lang", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		after(function()
			eva.saver.delete()
		end)

		it("Should correct load default language", function()
			assert(eva.lang.get_lang() == "en")
		end)

		it("Should correct save lang prefs", function()
			assert(eva.lang.get_lang() == "en")

			eva.lang.set_lang("ru")
			assert(eva.lang.get_lang() == "ru")

			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json")

			assert(eva.lang.get_lang() == "ru")
		end)

		it("Should return lang values", function()
			assert(eva.lang.txt("restart") == "Restart")
			assert(eva.lang.txt("continue") == "Continue")

			eva.lang.set_lang("ru")

			assert(eva.lang.txt("restart") == "Заново")
			assert(eva.lang.txt("continue") == "Продолжить")
		end)

		it("Should return lang values with params", function()
			assert(eva.lang.txp("find_hint", 2) == "TAP ON: 2")
		end)

		it("Should correct return time format", function()
			assert(eva.lang.time_format(10) == "0:10")
			assert(eva.lang.time_format(60) == "1:00")

			assert(eva.lang.time_format(60 * 60 + 60) == "1h 01m")
			assert(eva.lang.time_format(60 * 60 * 48) == "2d 00h")
		end)
	end)
end