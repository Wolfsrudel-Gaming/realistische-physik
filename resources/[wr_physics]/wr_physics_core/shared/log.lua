--- wr_physics core: logging with levels and module tags.
-- Level via convar `wrp_log_level` (debug|info|warn|error), default info.
local Log = {}
local LEVELS = { debug = 1, info = 2, warn = 3, error = 4 }
local level = LEVELS.info

local COLORS = { debug = "^5", info = "^7", warn = "^3", error = "^1" }

function Log.setLevel(name)
    level = LEVELS[name] or LEVELS.info
end

local function emit(lvl, tag, fmt, ...)
    if LEVELS[lvl] < level then return end
    local ok, msg = pcall(string.format, fmt, ...)
    if not ok then msg = tostring(fmt) end
    print(("%s[wr_physics:%s] %s%s^7"):format(COLORS[lvl], tag or "core", lvl == "info" and "" or (lvl:upper() .. " "), msg))
end

--- Create a tagged logger: local log = WRP.Log.tag("vehicle")
function Log.tag(tag)
    return {
        debug = function(fmt, ...) emit("debug", tag, fmt, ...) end,
        info = function(fmt, ...) emit("info", tag, fmt, ...) end,
        warn = function(fmt, ...) emit("warn", tag, fmt, ...) end,
        error = function(fmt, ...) emit("error", tag, fmt, ...) end,
    }
end

if GetConvar then
    Log.setLevel(GetConvar("wrp_log_level", "info"))
end

WRP = WRP or {}
WRP.Log = Log
return Log
