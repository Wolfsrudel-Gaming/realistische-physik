--- wr_physics devtools (client): reference measurement runs (F111).
-- /wrp_measure            arm a run: 0-100 km/h (and 0-60 mph), then 100-0 braking distance
-- /wrp_measure vmax       record top speed until the command is issued again
-- Results are printed, shown as an overlay message and sent to the server log.
local Units = WRP.Units
local log = WRP.Log.tag("measure")

local run = nil

local function speedKmh(veh) return Units.msToKmh(GetEntitySpeed(veh)) end

local function finish(result)
    local lines = {}
    for _, l in ipairs(result) do lines[#lines + 1] = l end
    local text = table.concat(lines, "\n")
    log.info("%s", text:gsub("\n", " | "))
    if WRP.Overlay then WRP.Overlay.message(text, 15000) end
    TriggerServerEvent("wr_physics:server:measurement", { lines = lines })
    run = nil
end

local function targetsLine()
    local ok, sim = pcall(function() return exports.wr_physics_vehicle:getActiveVehicleSim() end)
    if not ok or not sim then return nil end
    return sim.specId
end

CreateThread(function()
    while true do
        if run then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh == 0 then
                finish({ "Messung abgebrochen (Fahrzeug verlassen)" })
            else
                local kmh = speedKmh(veh)
                local now = GetGameTimer()
                if run.kind == "accel" then
                    if run.phase == "armed" then
                        if kmh > 1.0 then
                            run.phase = "accel"
                            run.t0 = now
                            run.p0 = GetEntityCoords(veh)
                        end
                    elseif run.phase == "accel" then
                        if not run.t60mph and kmh >= 96.56 then run.t60mph = (now - run.t0) / 1000.0 end
                        if kmh >= 100.0 then
                            run.t100 = (now - run.t0) / 1000.0
                            run.d100 = #(GetEntityCoords(veh) - run.p0)
                            run.phase = "brakeWait"
                            if WRP.Overlay then WRP.Overlay.message(("0-100: %.2f s – jetzt voll bremsen"):format(run.t100), 4000) end
                        elseif now - run.t0 > 60000 then
                            finish({ "0-100 nicht erreicht in 60 s" })
                        end
                    elseif run.phase == "brakeWait" then
                        if GetControlNormal(0, 72) > 0.5 then
                            run.phase = "brake"
                            run.bp0 = GetEntityCoords(veh)
                            run.bv0 = kmh
                            run.bt0 = now
                        end
                    elseif run.phase == "brake" then
                        if kmh < 1.0 then
                            local dist = #(GetEntityCoords(veh) - run.bp0)
                            local tb = (now - run.bt0) / 1000.0
                            local spec = targetsLine()
                            finish({
                                ("Datenblatt: %s"):format(spec or "?"),
                                ("0-100 km/h: %.2f s  (0-60 mph: %s)  Strecke %.0f m"):format(run.t100, run.t60mph and ("%.2f s"):format(run.t60mph) or "-", run.d100),
                                ("Bremsung %.0f-0 km/h: %.1f m in %.2f s  (mittl. %.2f m/s²)"):format(run.bv0, dist, tb, Units.kmhToMs(run.bv0) / math.max(tb, 0.01)),
                            })
                        end
                    end
                elseif run.kind == "vmax" then
                    if kmh > run.vmax then run.vmax = kmh end
                end
            end
        end
        Wait(run and 0 or 250)
    end
end)

RegisterCommand("wrp_measure", function(_, args)
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then log.info("sit in a vehicle first") return end
    if args[1] == "vmax" then
        if run and run.kind == "vmax" then
            finish({ ("Vmax: %.1f km/h (%.1f mph)"):format(run.vmax, Units.msToMph(Units.kmhToMs(run.vmax))) })
        else
            run = { kind = "vmax", vmax = 0.0 }
            if WRP.Overlay then WRP.Overlay.message("Vmax-Messung läuft – /wrp_measure vmax zum Beenden", 5000) end
        end
        return
    end
    if speedKmh(veh) > 1.0 then
        log.info("stop the vehicle first")
        return
    end
    run = { kind = "accel", phase = "armed" }
    if WRP.Overlay then WRP.Overlay.message("Messung scharf: Vollgas bis 100 km/h, dann voll bremsen", 5000) end
end, false)
