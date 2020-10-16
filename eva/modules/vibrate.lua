--- Eva vibrate module
-- It uses two different native extensions to unify vibrate API on
-- Android and iOS.
-- For use it you should add dependencies for vibrate for Android and iOS (see dependencies.txt)
-- @submodule eva

local const = require("eva.const")

local device = require("eva.modules.device")
local storage = require("eva.modules.storage")


local M = {}


--- Make phone vibrate
-- @function eva.vibrate.vibrate
-- @tparam number vibrate_pattern Vibrate const.VIBRATE
function M.vibrate(vibrate_pattern)
    if not storage.get(const.STORAGE.VIBRATE_IS_ENABLED) then
        return
    end

    if device.is_android() and vibrate then
        print("Vibrate", vibrate_pattern.Android)
        vibrate.vibrate(vibrate_pattern.Android)
    end

    if device.is_ios() and taptic_engine and taptic_engine.isSupported() then
        -- TODO: Get the iOS device with taptic engine for tests
        taptic_engine.impact(vibrate_pattern.iOS)
    end
end


--- Return if vibrate is enabled for user
-- @function eva.vibrate.is_enabled
-- @treturn boolean|nil Is vibrate enabled
function M.is_enabled()
    return storage.get(const.STORAGE.VIBRATE_IS_ENABLED)
end


--- Turn on or off vibrate for user
-- @function eva.vibrate.set_enabled
-- @tparam boolean is_enabled Vibrate state
function M.set_enabled(is_enabled)
    storage.set(const.STORAGE.VIBRATE_IS_ENABLED, is_enabled)
end


function M.after_eva_init()
    if M.is_enabled() == nil then
        M.set_enabled(true)
    end
end


return M
