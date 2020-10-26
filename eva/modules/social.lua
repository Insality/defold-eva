--- Social Eva module
-- Handle any social connection
-- For example: Facebook, Google Play Game Services and Game Center
-- @submodule eva

local app = require("eva.app")
local SocialStub = require("eva.modules.social.stub")
local SocialGPGS = require("eva.modules.social.gpgs")

local device = require("eva.modules.device")

local M = {}


function M.login_platform()
    app._social_data.platform:login()
end


function M.logout_platform()
    app._social_data.platform:logout()
end


function M.is_logged()
    return app._social_data.platform:is_logged()
end


function M.login_toggle_platform()
    if M.is_logged() then
        M.logout_platform()
    else
        M.login_platform()
    end
end


function M.after_eva_init()
    app._social_data = {
        platform = SocialStub()
    }

    if device.is_android() and gpgs then
        app._social_data.platform = SocialGPGS()
    end
end


return M
