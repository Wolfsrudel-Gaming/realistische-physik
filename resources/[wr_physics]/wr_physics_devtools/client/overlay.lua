--- wr_physics devtools (client): telemetry overlay (NUI).
-- /wrp_telemetry toggles the panel. Data arrives via the local event the vehicle module fires.
local Config = WRP.Config
local log = WRP.Log.tag("devtools")

local Overlay = { visible = Config.devtools.telemetryDefaultOn, lastSched = 0 }

function Overlay.setVisible(on)
    Overlay.visible = on
    SendNUIMessage({ type = "visible", on = on })
end

function Overlay.message(text, ms)
    SendNUIMessage({ type = "message", text = text, ms = ms or 6000 })
end

AddEventHandler("wr_physics:client:telemetry", function(snap)
    if not Overlay.visible then return end
    SendNUIMessage({ type = "telemetry", data = snap })
    local now = GetGameTimer()
    if now - Overlay.lastSched > 500 then
        Overlay.lastSched = now
        local ok, stats = pcall(function() return exports.wr_physics_core:getSchedulerStats() end)
        if ok and stats then
            SendNUIMessage({ type = "sched", avgMs = stats.avgMs, degrade = stats.degradeLevel })
        end
    end
end)

RegisterCommand("wrp_telemetry", function()
    Overlay.setVisible(not Overlay.visible)
    log.info("telemetry overlay %s", Overlay.visible and "on" or "off")
end, false)
RegisterKeyMapping("wrp_telemetry", "wr_physics Telemetrie ein/aus", "keyboard", "F10")

CreateThread(function()
    Wait(1000)
    Overlay.setVisible(Overlay.visible)
end)

WRP.Overlay = Overlay
