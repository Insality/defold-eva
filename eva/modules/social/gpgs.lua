--- Gpgs platform module adapter
-- @module platform.gpgs
-- @local
local class = require("eva.libs.middleclass")
local SocialStub = require("eva.modules.social.stub")

local M = class("eva.social.gpgs", SocialStub)


function M:initialize()
    gpgs.set_callback(self._gpgs_callback)
    gpgs.silent_login()
end


function M:login()
    gpgs.login()
end


function M:logout()
    gpgs.logout()
end


function M:is_logged()
    return gpgs.is_logged_in()
end


function M:get_id()
    return gpgs.get_id()
end


function M:get_username()
    return gpgs.get_display_name()
end


function M:_gpgs_callback(_, message_id, message)
    if message_id == gpgs.MSG_SIGN_IN or message_id == gpgs.MSG_SILENT_SIGN_IN then
        if message.status == gpgs.STATUS_SUCCESS then
            print("Signed in")
            print(gpgs.get_id())
            print(gpgs.get_display_name())
        else
            print("Sign in error!")
            pprint(message)
        end
    elseif message_id == gpgs.MSG_SIGN_OUT then
        print("Signed out")
    end
    pprint("Message:", message_id, message)
end


return M
