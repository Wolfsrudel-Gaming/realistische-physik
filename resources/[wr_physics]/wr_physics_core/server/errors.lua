--- wr_physics core (server): error log (F116).
-- Client and server errors are appended as JSON lines to logs/errors.jsonl inside the resource
-- folder (one file per day). The test-server update script collects these files.
local log = WRP.Log.tag("errors")
local resource = GetCurrentResourceName()
local counts = {}
local MAX_PER_CLIENT_PER_MINUTE = 20
local clientBudget = {}

local function append(entry)
    local day = os.date("!%Y-%m-%d")
    local path = ("logs/errors-%s.jsonl"):format(day)
    local existing = LoadResourceFile(resource, path) or ""
    entry.ts = os.date("!%Y-%m-%dT%H:%M:%SZ")
    SaveResourceFile(resource, path, existing .. json.encode(entry) .. "\n", -1)
end

local function record(entry)
    local key = (entry.module or "?") .. ":" .. (entry.err or ""):sub(1, 120)
    counts[key] = (counts[key] or 0) + 1
    entry.count = counts[key]
    if counts[key] <= 3 or counts[key] % 50 == 0 then
        append(entry)
    end
end

RegisterNetEvent("wr_physics:server:clientError", function(data)
    local src = source
    if type(data) ~= "table" then return end
    local now = os.time()
    local b = clientBudget[src]
    if not b or now - b.t > 60 then b = { t = now, n = 0 }; clientBudget[src] = b end
    b.n = b.n + 1
    if b.n > MAX_PER_CLIENT_PER_MINUTE then return end
    record({
        side = "client",
        source = src,
        player = GetPlayerName(src),
        identifier = WRP.Bridge.identifier(src),
        module = tostring(data.module):sub(1, 64),
        err = tostring(data.err):sub(1, 4000),
        build = data.build,
    })
    log.warn("client %s [%s]: %s", GetPlayerName(src), tostring(data.module), tostring(data.err):match("^[^\n]*"))
end)

--- Server-side guard mirroring the client one.
function WRP.guard(module, fn, ...)
    local ok, a, b, c = xpcall(fn, debug.traceback, ...)
    if not ok then
        log.error("[%s] %s", module, tostring(a))
        record({ side = "server", module = module, err = tostring(a) })
        return nil
    end
    return a, b, c
end

WRP.recordError = record
