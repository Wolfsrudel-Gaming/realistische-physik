--- wr_physics core: minimal class helper.
-- Usage:
--   local Engine = class("Engine")
--   function Engine:init(spec) ... end
--   local e = Engine.new(spec)
local function class(name, parent)
    local c = {}
    c.__index = c
    c.__name = name
    if parent then setmetatable(c, { __index = parent }) end
    c.new = function(...)
        local o = setmetatable({}, c)
        if o.init then o:init(...) end
        return o
    end
    c.super = parent
    return c
end

WRP = WRP or {}
WRP.class = class
return class
