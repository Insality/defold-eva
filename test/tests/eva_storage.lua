local eva = require("eva.eva")

return function()
	describe("Eva storage", function()
		before(function()
			eva.init("/resources/tests/eva_tests.json")
		end)

		after(function()
			eva.saver.delete()
		end)

		it("Should correct add/get storage value", function()
			eva.storage.set("string_value", "value")
			eva.storage.set("number_value", 20)
			eva.storage.set("bool_value", true)

			assert(eva.storage.get("string_value") == "value")
			assert(eva.storage.get("number_value") == 20)
			assert(eva.storage.get("bool_value") == true)

			eva.storage.set("number_value", 30)
			assert(eva.storage.get("number_value") == 30)
		end)

		it("Should correct save values after save/load", function()
			eva.storage.set("string_value", "value")
			eva.storage.set("number_value", 20)
			eva.storage.set("bool_value", true)

			eva.saver.save()
			eva.init("/resources/tests/eva_tests.json")

			assert(eva.storage.get("string_value") == "value")
			assert(eva.storage.get("number_value") == 20)
			assert(eva.storage.get("bool_value") == true)
		end)
	end)
end