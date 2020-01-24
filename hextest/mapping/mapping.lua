local eva = require("eva.eva")

local M = {}


function M.make_object(prefix, group, id, position)
	local mapping = eva.db.get("TiledMapping")

	local object_data = mapping[group][tostring(id)]
	local object_name = object_data.object_name
	local object_image = object_data.image_name

	local spawner_url = string.format("%s/spawner_%s#%s", prefix, group, object_name)
	local object = factory.create(spawner_url, position)

	sprite.play_flipbook(object, object_image)

	return object
end


return M