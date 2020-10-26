local class = require("eva.libs.middleclass")

local M = class("eva.social.stub")


function M:login()
    error("abstact method")
end


function M:logout()
    error("abstact method")
end


function M:is_logged()
    error("abstact method")
end


function M:get_id()
    error("abstact method")
end


function M:get_username()
    error("abstact method")
end


function M:after_eva_init()
    error("abstact method")
end


return M
