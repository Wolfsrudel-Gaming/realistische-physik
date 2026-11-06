--- wr_physics core (server): startup, status endpoint, admin command.
local log = WRP.Log.tag("core")
local Config = WRP.Config
local resource = GetCurrentResourceName()
local version = GetResourceMetadata(resource, "version", 0) or "?"

WRP.Locale.load(resource)
log.info(WRP.t("core.started", version))
log.info(WRP.t("core.framework", WRP.Bridge.name))

function WRP.moduleEnabled(name)
    if Config.modules[name] == false then
        log.warn(WRP.t("core.module_disabled", name))
        return false
    end
    return true
end

local function status()
    return {
        resource = resource,
        version = version,
        framework = WRP.Bridge.name,
        db = WRP.DB.ready,
        modules = Config.modules,
        world = Config.world,
        build = GetConvarInt("sv_enforceGameBuild", 0),
        players = #GetPlayers(),
    }
end

--- Minimal HTTP status endpoint for the web panel / monitoring:
--   http://<server>:<port>/wr_physics_core/status
SetHttpHandler(function(req, res)
    if req.path == "/status" then
        res.writeHead(200, { ["Content-Type"] = "application/json" })
        res.send(json.encode(status()))
    else
        res.writeHead(404)
        res.send("not found")
    end
end)

RegisterCommand("wrp_status", function(src)
    if src ~= 0 and not WRP.Bridge.isAdmin(src) then return end
    local s = status()
    local msg = ("wr_physics %s | framework %s | db %s | build %d | world.scale %.2f"):format(
        s.version, s.framework, tostring(s.db), s.build, s.world.scale)
    if src == 0 then print(msg) else TriggerClientEvent("chat:addMessage", src, { args = { "wr_physics", msg } }) end
end, true)

exports("getConfig", function() return Config.snapshot() end)
exports("recordError", function(entry) WRP.recordError(entry) end)
exports("loadVehicle", function(plate, model) return WRP.DB.loadVehicle(plate, model) end)
exports("saveVehicleState", function(...) return WRP.DB.saveVehicleState(...) end)
