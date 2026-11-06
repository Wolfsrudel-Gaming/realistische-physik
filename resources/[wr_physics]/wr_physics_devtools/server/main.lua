--- wr_physics devtools (server): collects measurement results into logs/measurements.jsonl.
local log = WRP.Log.tag("devtools")
local Config = WRP.Config
local resource = GetCurrentResourceName()

if not Config.modules.devtools then
    log.warn("devtools disabled by configuration (wrp_modules_devtools 0)")
    return
end

RegisterNetEvent("wr_physics:server:measurement", function(data)
    local src = source
    if type(data) ~= "table" or type(data.lines) ~= "table" then return end
    local entry = {
        ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        player = GetPlayerName(src),
        identifier = WRP.Bridge.identifier(src),
        lines = {},
    }
    for i = 1, math.min(#data.lines, 10) do entry.lines[i] = tostring(data.lines[i]):sub(1, 300) end
    local existing = LoadResourceFile(resource, "logs/measurements.jsonl") or ""
    SaveResourceFile(resource, "logs/measurements.jsonl", existing .. json.encode(entry) .. "\n", -1)
    log.info("measurement from %s: %s", entry.player, table.concat(entry.lines, " | "))
end)

log.info("devtools ready")
