--- wr_physics core (client): startup and exports.
local log = WRP.Log.tag("core")
local Config = WRP.Config

WRP.Locale.load(GetCurrentResourceName())
log.info(WRP.t("core.started", GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "?"))
log.info(WRP.t("core.framework", WRP.Bridge.name))

--- Modules call this at startup; returns false (and logs) if the module is disabled by config.
function WRP.moduleEnabled(name)
    local flag = Config.modules[name]
    if flag == false then
        log.warn(WRP.t("core.module_disabled", name))
        return false
    end
    return true
end

-- Exports for other resources (read-only access to the core namespace).
exports("getConfig", function() return Config.snapshot() end)
exports("getSchedulerStats", function() return WRP.Scheduler.stats() end)
exports("getPlayerVehicle", function() return WRP.Player.vehicle, WRP.Player.seat, WRP.Player.isDriver end)

-- Note: sibling resources include the core libraries via '@wr_physics_core/...' paths in their
-- manifest and therefore run their own copy of the WRP namespace. Live core state is shared
-- through the local events fired by client/player.lua and through the exports above
-- (functions cannot cross resource boundaries).
