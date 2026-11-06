--- wr_physics vehicle (client): lifecycle of the driven vehicle's simulation.
--
-- When the local player becomes the driver, a Drivetrain + Fuel simulation is created from the
-- model's datasheet (or the class fallback) and stepped every frame with substeps. Results are
-- written back to the game (rpm, gear, clutch, engine on/off, fuel) and the Coupling drives the
-- game's longitudinal dynamics. Telemetry goes out as a local event for the devtools overlay and,
-- throttled, into the entity state bag for other clients.
local wmath = WRP.Math
local Units = WRP.Units
local Config = WRP.Config
local log = WRP.Log.tag("vehicle")
local Registry = WRP.SpecRegistry
local Drivetrain = WRP.Sim.Drivetrain
local Fuel = WRP.Sim.Fuel
local Input = WRP.VehicleInput
local Coupling = WRP.VehicleCoupling

WRP.Locale.load(GetCurrentResourceName())

if not Config.modules.vehicle then
    log.warn("module disabled by configuration (wrp_modules_vehicle 0)")
    return
end
log.info(WRP.t("veh.module_started", Config.vehicle.coupling))

local active = nil   -- current simulation context

local function modelName(veh)
    return (GetDisplayNameFromVehicleModel(GetEntityModel(veh)) or "unknown"):lower()
end

--- Average angular speed of the driven wheels [rad/s], signed with travel direction.
local function drivenWheelRadS(ctx)
    local veh, spec = ctx.veh, ctx.spec
    local n = GetVehicleNumberOfWheels(veh)
    if n < 2 then
        return GetEntitySpeedVector(veh, true).y / spec.wheels.radius
    end
    local layout = spec.drivetrain.layout
    local idx
    if n == 2 then idx = { 1 } -- bikes: rear
    elseif layout == "FWD" then idx = { 0, 1 }
    elseif layout == "RWD" then idx = { 2, 3 }
    else idx = { 0, 1, 2, 3 } end
    local sum, cnt = 0.0, 0
    for _, i in ipairs(idx) do
        if i < n then
            sum = sum + GetVehicleWheelSpeed(veh, i)
            cnt = cnt + 1
        end
    end
    local sign = GetEntitySpeedVector(veh, true).y >= 0 and 1 or -1
    local v = cnt > 0 and (sum / cnt) or GetEntitySpeed(veh)
    return sign * math.abs(v) / spec.wheels.radius
end

local function notify(msg)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function startSim(veh)
    local name = modelName(veh)
    local spec, fallback = Registry.forModel(name, GetVehicleClass(veh))
    if fallback and not Config.vehicle.allowClassFallback then
        log.info("no datasheet for %s and fallback disabled", name)
        return
    end
    if fallback then
        log.warn(WRP.t("veh.spec_fallback", name, spec.name))
    else
        log.info(WRP.t("veh.spec_loaded", spec.name, spec.id))
    end

    local ctx = {
        veh = veh,
        netId = NetworkGetNetworkIdFromEntity(veh),
        model = name,
        spec = spec,
        fallback = fallback,
        drivetrain = Drivetrain.new(spec),
        fuel = Fuel.new(spec.fuel, Config.world.scale),
        coupling = Coupling.new(veh, spec),
        odometerM = 0.0,
        engineHours = 0.0,
        vin = nil,
        telemetryAt = 0,
        stateBagAt = 0,
        saveAt = GetGameTimer() + 30000,
        starterTimer = 0.0,
    }

    -- Engine state on entry: realistic mode leaves the engine off until the driver starts it.
    local gameEngineOn = GetIsVehicleEngineRunning(veh)
    if Config.vehicle.autoStartOnEnter or (gameEngineOn and Entity(veh).state["wrp:engineOn"]) then
        ctx.drivetrain.engine:forceRunning()
    else
        SetVehicleEngineOn(veh, false, true, true)
    end
    if not ctx.drivetrain.gearbox:isManual() then ctx.drivetrain.gearbox:setLever("P") end

    -- Persisted state (fuel, odometer) arrives asynchronously from the server.
    TriggerServerEvent("wr_physics:server:requestVehicleState", ctx.netId, GetVehicleNumberPlateText(veh), name)
    -- Until then use the game's fuel level as a starting point.
    ctx.fuel.levelL = wmath.clamp(GetVehicleFuelLevel(veh) / 100.0, 0.0, 1.0) * spec.fuel.tankL

    Input.reset()
    active = ctx

    WRP.Scheduler.register("vehicle.sim", 0, 1, function(dt) WRP.VehicleTick(dt) end)
end

local function stopSim(save)
    local ctx = active
    if not ctx then return end
    WRP.Scheduler.unregister("vehicle.sim")
    if DoesEntityExist(ctx.veh) then
        ctx.coupling:release()
        Entity(ctx.veh).state:set("wrp:engineOn", ctx.drivetrain.engine.running, true)
    end
    if save then
        TriggerServerEvent("wr_physics:server:saveVehicleState", ctx.netId, {
            vin = ctx.vin, odometerM = ctx.odometerM, fuelL = ctx.fuel.levelL, engineHours = ctx.engineHours,
        })
    end
    active = nil
    TriggerEvent("wr_physics:client:telemetry", nil)
end

RegisterNetEvent("wr_physics:client:vehicleState", function(netId, data)
    local ctx = active
    if not ctx or ctx.netId ~= netId or type(data) ~= "table" then return end
    ctx.vin = data.vin
    if data.fuelL then ctx.fuel.levelL = wmath.clamp(data.fuelL, 0.0, ctx.spec.fuel.tankL) end
    if data.odometerM then ctx.odometerM = data.odometerM end
    if data.engineHours then ctx.engineHours = data.engineHours end
end)

--- Per-frame tick (registered with the scheduler at priority 1).
function WRP.VehicleTick(dt)
    local ctx = active
    if not ctx then return end
    local veh = ctx.veh
    if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= PlayerPedId() then
        stopSim(true)
        return
    end
    local dtr, eng, gb = ctx.drivetrain, ctx.drivetrain.engine, ctx.drivetrain.gearbox

    -- 1. Inputs. Block the game's throttle wherever the game must not drive on its own.
    local blockThrottle = not eng.running or gb.gear <= 0 or dtr.clutchEngagement < 0.5 or gb:isShifting()
    local inp = Input.sample(dt, blockThrottle)

    if inp.shiftUp then
        if gb:isManual() then gb:shiftUp()
        else
            local order = { P = "R", R = "N", N = "D", D = "D" }
            gb:setLever(order[gb.lever] or "D")
        end
    end
    if inp.shiftDown then
        if gb:isManual() then gb:shiftDown()
        else
            local order = { D = "N", N = "R", R = "P", P = "P" }
            gb:setLever(order[gb.lever] or "P")
        end
    end
    if inp.engineToggle then
        if eng.running then
            eng:shutOff()
        elseif not ctx.fuel:isEmpty() then
            -- Start only in neutral/P or with the clutch pressed (manual).
            local canStart = gb:isManual() and (gb.gear == 0 or inp.clutch > 0.8) or (not gb:isManual() and (gb.lever == "P" or gb.lever == "N"))
            if canStart then eng:startCranking() end
        end
    end
    if ctx.fuel:isEmpty() and eng.running then
        eng:shutOff()
        notify(WRP.t("veh.no_fuel"))
    end

    -- 2. Simulation with substeps.
    local wheelRadS = drivenWheelRadS(ctx)
    local v = GetEntitySpeedVector(veh, true).y
    local wasRunning = eng.running
    local n = math.max(1, Config.performance.substeps)
    local sub = dt / n
    local torque = 0.0
    for _ = 1, n do
        torque = dtr:step(sub, inp.throttle, inp.clutch, wheelRadS, v)
    end
    if wasRunning and not eng.running and not eng.cranking then notify(WRP.t("veh.stalled")) end

    local moving = math.abs(v) > 0.5
    ctx.fuel:step(dt, eng, moving)
    if moving then ctx.odometerM = ctx.odometerM + math.abs(v) * dt * Config.world.scale end
    if eng.running then ctx.engineHours = ctx.engineHours + dt / 3600.0 end

    -- 3. Write back to the game.
    local rpmNorm = wmath.clamp(eng:rpm() / ctx.spec.engine.maxRpm, 0.0, 1.0)
    if eng.running or eng.cranking then
        if not GetIsVehicleEngineRunning(veh) then SetVehicleEngineOn(veh, true, true, true) end
        SetVehicleCurrentRpm(veh, math.max(rpmNorm, 0.08))
    else
        if GetIsVehicleEngineRunning(veh) then SetVehicleEngineOn(veh, false, true, true) end
        SetVehicleCurrentRpm(veh, 0.0)
    end
    local gtaGear = math.max(0, math.min(gb.gear, GetVehicleHighGear(veh)))
    SetVehicleCurrentGear(veh, gtaGear)
    SetVehicleNextGear(veh, gtaGear)
    SetVehicleClutch(veh, dtr.clutchEngagement)
    if Config.vehicle.syncGameFuel ~= false then
        SetVehicleFuelLevel(veh, ctx.fuel:fraction() * 100.0)
    end

    -- 4. Longitudinal coupling.
    ctx.coupling:step(dt, dtr.wheelForce, inp, eng.running)

    -- 5. Telemetry (local event, 20 Hz) and state bag (replicated, Config rate).
    local now = GetGameTimer()
    if now >= ctx.telemetryAt then
        ctx.telemetryAt = now + 50
        local snap = dtr:snapshot()
        snap.speedKmh = Units.msToKmh(math.abs(v))
        snap.speedMph = Units.msToMph(math.abs(v))
        snap.throttle = inp.throttle
        snap.brake = inp.brake
        snap.clutchPedal = inp.clutch
        snap.fuelL = ctx.fuel.levelL
        snap.fuelFlowLh = ctx.fuel.flowLh
        snap.tankL = ctx.spec.fuel.tankL
        snap.odometerKm = ctx.odometerM / 1000.0
        snap.aDes = ctx.coupling.aDes
        snap.aMeas = ctx.coupling.aMeas
        snap.powerMult = ctx.coupling.mult
        snap.residualN = ctx.coupling.residualN
        snap.coupling = ctx.coupling.mode
        snap.specName = ctx.spec.name
        snap.specId = ctx.spec.id
        snap.fallback = ctx.fallback
        snap.units = ctx.spec.display.units
        snap.maxRpm = ctx.spec.engine.maxRpm
        snap.redlineRpm = ctx.spec.engine.redlineRpm
        snap.numGears = gb.numGears
        snap.manual = gb:isManual()
        snap.wheelRadS = wheelRadS
        snap.torqueNm = torque
        TriggerEvent("wr_physics:client:telemetry", snap)
    end
    if now >= ctx.stateBagAt and NetworkHasControlOfEntity(veh) then
        ctx.stateBagAt = now + math.floor(1000 / math.max(Config.performance.stateBagHz, 1))
        Entity(veh).state:set("wrp:veh", {
            rpm = math.floor(eng:rpm()), gear = gb.gear, on = eng.running,
            fuel = wmath.round(ctx.fuel:fraction(), 2), spec = ctx.spec.id,
        }, true)
    end
    if now >= ctx.saveAt then
        ctx.saveAt = now + 30000
        TriggerServerEvent("wr_physics:server:saveVehicleState", ctx.netId, {
            vin = ctx.vin, odometerM = ctx.odometerM, fuelL = ctx.fuel.levelL, engineHours = ctx.engineHours,
        })
    end
end

AddEventHandler("wr_physics:client:becameDriver", function(veh)
    if active then stopSim(true) end
    WRP.guard("vehicle.start", startSim, veh)
end)
AddEventHandler("wr_physics:client:lostDriver", function() stopSim(true) end)
AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() then stopSim(true) end
end)

-- Commands --------------------------------------------------------------------------------------
RegisterCommand("wrp_coupling", function(_, args)
    local mode = args[1]
    if mode ~= "power" and mode ~= "force" and mode ~= "hybrid" then
        log.info("usage: /wrp_coupling power|force|hybrid (current: %s)", Config.vehicle.coupling)
        return
    end
    Config.vehicle.coupling = mode
    if active then active.coupling:setMode(mode) end
    log.info("coupling mode: %s", mode)
end, false)

RegisterCommand("wrp_spec", function()
    if not active then log.info("not driving") return end
    local s = active.spec
    log.info("%s (%s) status=%s %s | %.0f kg | %.0f PS @ %d | %.0f Nm @ %d | %s %d gears | %s | r=%.3f m",
        s.name, s.id, s.meta.status, active.fallback and "[FALLBACK]" or "", s.mass.curb,
        s.derived.powerPeakPS, s.derived.powerPeakRpm, s.derived.torquePeakNm, s.derived.torquePeakRpm,
        s.gearbox.type, s.derived.numGears, s.drivetrain.layout, s.wheels.radius)
end, false)

exports("getActiveVehicleSim", function()
    if not active then return nil end
    local snap = active.drivetrain:snapshot()
    snap.specId = active.spec.id
    snap.fuelL = active.fuel.levelL
    return snap
end)
