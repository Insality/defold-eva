--- Eva share module. This module require next dependencies (see dependencies.txt):
--- defold-sharing
--- defold-screenshot


local log = require("eva.log")

local logger = log.get_logger("eva.share")

local M = {}


--- Share screenshot of the game
-- @function eva.share.screen
-- @tparam string text The optional text to share with screenshot
function M.screen(text)
    if not M.is_supported() then
        logger:info("The eva.share module is not available on this platform")
    end

    local buffer = screenshot.png()
    pprint(buffer)
    share.image(buffer, text)
    print("After share")
end


function M.is_supported()
    if share and screenshot then
        return true
    end
    return false
end


return M
