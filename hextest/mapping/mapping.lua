local eva = require("eva.eva")

local M = {}


function M.make_object(prefix, spawner_name, id, position)
	local mapping = eva.tiled.get_mapping()

	local object_data = mapping[spawner_name][tostring(id)]
	local object_name = object_data.object_name
	local object_image = object_data.image_name

	local spawner_url = string.format("%s/spawner_%s#%s", prefix, spawner_name, object_name)
	local object = factory.create(spawner_url, position)

	sprite.play_flipbook(object, object_image)

	return object
end


return M