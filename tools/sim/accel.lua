--- wr_physics offline simulator: straight-line acceleration / top speed check (F111).
-- Usage: lua5.4 tools/sim/accel.lua [datasheet_id ...]
-- Simulates 0-100 km/h, 0-200 km/h (if reachable) and top speed with the drivetrain model
-- plus drag, rolling resistance and a static traction limit, and compares with the datasheet targets.
local root = arg[0]:match("^(.*)/tools/sim/accel%.lua$") or "."
local function load(rel)
    local chunk, err = loadfile(root .. "/" .. rel)
    if not chunk then error(err) end
    return chunk()
end
WRP = {}
local core = "resources/[wr_physics]/wr_physics_core/shared/"
for _, f in ipairs { "lib/class.lua", "lib/wmath.lua", "lib/units.lua", "lib/curve.lua", "lib/vec.lua", "lib/deepmerge.lua" } do
    load(core .. f)
end
local veh = "resources/[wr_physics]/wr_physics_vehicle/"
for _, f in ipairs { "shared/sim/engine.lua", "shared/sim/gearbox.lua", "shared/sim/drivetrain.lua",
    "shared/sim/fuel.lua", "shared/sim/longitudinal.lua", "shared/specs/spec.lua", "shared/specs/classes.lua",
    "data/vehicles/reference.lua", "shared/specs/registry.lua" } do
    load(veh .. f)
end

local Registry, Drivetrain, Long, Units = WRP.SpecRegistry, WRP.Sim.Drivetrain, WRP.Sim.Longitudinal, WRP.Units
local DT = 1 / 200

local function run(id)
    local spec = Registry.byId(id)
    if not spec then print("unknown datasheet: " .. id) return end
    local dt = Drivetrain.new(spec)
    local gb = dt.gearbox
    local e = dt.engine
    e:forceRunning()
    if gb:isManual() then gb:requestGear(1) else gb:setLever("D") end

    local v, t, a = 0.0, 0.0, 0.0
    local t100, t200, vmax = nil, nil, 0.0
    local shiftRpm = spec.engine.redlineRpm - 150
    local launchTime = 0.9
    local tLast = 0.0

    while t < 90.0 do
        local clutch = 0.0
        if gb:isManual() then
            if t < launchTime then clutch = (1.0 - t / launchTime) * 0.75 end
            if e:rpm() > shiftRpm and gb.gear < gb.numGears and not gb:isShifting() then
                gb:requestGear(gb.gear + 1)
            end
        end
        local wheelRadS = dt:wheelRadSFromSpeed(v)
        local torque = dt:step(DT, 1.0, clutch, wheelRadS, v)
        local f = torque / spec.wheels.radius
        local limit = Long.tractionLimit(spec, spec.mass.curb, a)
        if f > limit then f = limit end
        f = f - Long.dragForce(spec, v) - Long.rollingForce(spec, v)
        a = f / spec.mass.curb
        v = math.max(0.0, v + a * DT)
        t = t + DT
        local kmh = Units.msToKmh(v)
        if not t100 and kmh >= 100 then t100 = t end
        if not t200 and kmh >= 200 then t200 = t end
        if v > vmax then vmax = v; tLast = t end
        if t - tLast > 5.0 and t > 20.0 then break end  -- speed has settled
        if not e.running then break end
    end

    local tg = spec.targets or {}
    local function pct(actual, target)
        if not target or target == 0 then return "" end
        return ("(%+.0f%%)"):format((actual - target) / target * 100)
    end
    print(("%-32s %-6s 0-100: %5.2fs %-7s  0-200: %s  vmax: %5.1f km/h %-7s  P: %3.0f PS  stall:%s"):format(
        spec.name, spec.gearbox.type,
        t100 or -1, t100 and pct(t100, tg.acceleration0to100) or "",
        t200 and ("%5.2fs"):format(t200) or "  -   ",
        Units.msToKmh(vmax), pct(Units.msToKmh(vmax), tg.topSpeedKmh),
        spec.derived.powerPeakPS, tostring(not e.running)))
end

local ids = {}
for i = 1, #arg do ids[#ids + 1] = arg[i] end
if #ids == 0 then ids = Registry.ids() end
for _, id in ipairs(ids) do run(id) end
