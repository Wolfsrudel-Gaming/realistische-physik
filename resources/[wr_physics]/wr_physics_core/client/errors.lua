--- wr_physics core (client): error reporter (F116).
-- Modules wrap their per-frame work in WRP.guard(); errors are logged once per unique message,
-- rate-limited, and forwarded to the server which writes them to the error log.
local log = WRP.Log.tag("errors")
local seen = {}
local reported = 0
local MAX_REPORTS_PER_SESSION = 50

local function report(module, err)
    local key = tostring(err):sub(1, 200)
    if seen[key] then
        seen[key] = seen[key] + 1
        return
    end
    seen[key] = 1
    log.error("[%s] %s", module, tostring(err))
    if reported < MAX_REPORTS_PER_SESSION then
        reported = reported + 1
        TriggerServerEvent("wr_physics:server:clientError", {
            module = module,
            err = tostring(err),
            build = GetGameBuildNumber and GetGameBuildNumber() or 0,
            time = GetGameTimer(),
        })
    end
end

--- Run fn(...) protected; on error report it with the module tag and return nil.
function WRP.guard(module, fn, ...)
    local ok, a, b, c = xpcall(fn, debug.traceback, ...)
    if not ok then
        report(module, a)
        return nil
    end
    return a, b, c
end

WRP.reportError = report
