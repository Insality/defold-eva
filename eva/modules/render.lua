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


function M.set_clear_color(color)
	msg.post("@render:", "clear_color", { color = color })
end


function M.on_eva_update(dt)
	-- model.set_constant("/render#default", "time", M.time)
end


return M
