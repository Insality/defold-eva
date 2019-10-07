--- Eva render module
-- Can adjust different game render settings
-- and effects
-- @submodule eva


local M = {}


--- Change render
-- @function eva.render.set_blur
function M.set_blur(power)

end


--- Change render
-- @function eva.render.set_light
function M.set_light(power)

end


--- Change render
-- @function eva.render.set_vignette
function M.set_vignette(power)

end


function M.on_game_update(dt)
	model.set_constant("/render#default", "light", vmath.vector4(math.sin(socket.gettime())*10 + 11, 0, 0, 0))
end


return M
