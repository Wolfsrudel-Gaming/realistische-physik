--- wr_physics vehicle: datasheet schema, defaults and resolver.
--
-- A datasheet ("spec") describes one real vehicle. Authors write the raw table (see data/vehicles),
-- Spec.resolve() validates it, fills class defaults and derives everything the simulation needs
-- (wheel radius from the tyre size, a torque curve from peak values if no curve is given, ...).
--
-- Status values: "draft" (auto/estimated), "reviewed", "approved" (F102).
local wmath = WRP.Math
local Units = WRP.Units
local Table = WRP.Table

local Spec = {}

Spec.STATUS = { DRAFT = "draft", REVIEWED = "reviewed", APPROVED = "approved" }

--- Parse a metric tyre designation like "215/45R17" -> radius [m].
function Spec.tyreRadius(designation)
    local width, aspect, rim = designation:match("^(%d+)/(%d+)%s*[RZ]+%s*(%d+%.?%d*)$")
    if not width then
        error("Spec.tyreRadius: cannot parse tyre size '" .. tostring(designation) .. "'")
    end
    width, aspect, rim = tonumber(width), tonumber(aspect), tonumber(rim)
    local sidewall = width * aspect / 100.0 / 1000.0
    local rimRadius = Units.inToM(rim) / 2.0
    return rimRadius + sidewall
end

--- Build a plausible WOT torque curve from peak torque/power figures.
-- Returns { {rpm, Nm}, ... }
function Spec.synthTorqueCurve(e)
    local tPeak, tRpm = e.torquePeakNm, e.torquePeakRpm
    local pPeakW, pRpm = e.powerPeakW, e.powerPeakRpm
    local redline = e.redlineRpm
    local idle = e.idleRpm
    assert(tPeak and tRpm and pPeakW and pRpm and redline and idle, "synthTorqueCurve: missing peak data")
    local tAtPowerPeak = pPeakW / (pRpm * Units.RADS_PER_RPM)
    local turbo = e.aspiration == "turbo" or e.aspiration == "supercharged"
    local pts = {}
    pts[#pts + 1] = { idle, tPeak * (turbo and 0.45 or 0.62) }
    local mid = (idle + tRpm) / 2.0
    pts[#pts + 1] = { mid, tPeak * (turbo and 0.72 or 0.84) }
    pts[#pts + 1] = { tRpm, tPeak }
    if turbo then
        -- Flat torque plateau typical for turbo engines.
        local plateauEnd = math.min(pRpm - 300.0, tRpm + 1500.0)
        if plateauEnd > tRpm then pts[#pts + 1] = { plateauEnd, tPeak * 0.985 } end
    end
    pts[#pts + 1] = { pRpm, tAtPowerPeak }
    if redline > pRpm then
        pts[#pts + 1] = { redline, tAtPowerPeak * 0.86 }
    end
    return pts
end

local defaults = {
    meta = { status = Spec.STATUS.DRAFT, source = "estimated", version = 1 },
    engine = {
        aspiration = "na",
        idleRpm = 800,
        friction = { a = 20.0, b = 6.0 },   -- Nm, Nm/1000rpm (closed throttle)
        starterTorque = 60.0,
        crankRpm = 250,
        fireRpm = 220,
    },
    clutch = { lockSlipRpm = 60 },
    gearbox = { efficiency = 0.92, reverse = 3.5 },
    wheels = { crr = 0.012, muPeak = 1.0 },
    aero = { cl = 0.0 },
    geometry = { cgHeight = 0.52 },
    mass = { frontAxleFraction = 0.6 },
    fuel = { type = "petrol", bsfcMin = 240.0, idleFlowLh = 0.7 },
    drivetrain = { layout = "FWD" },
    assist = { abs = false, esp = false, tcs = false },
    display = { units = "metric", cluster = "modern_analog" },
}

local function req(t, path)
    local cur = t
    for part in path:gmatch("[^%.]+") do
        if type(cur) ~= "table" then cur = nil break end
        cur = cur[part]
    end
    if cur == nil then error("Spec: missing required field '" .. path .. "'") end
    return cur
end

--- Resolve a raw datasheet into a complete, simulation-ready spec.
function Spec.resolve(raw)
    local s = Table.deepmerge(defaults, raw)
    req(s, "id"); req(s, "name"); req(s, "year")
    req(s, "mass.curb"); req(s, "engine.maxRpm"); req(s, "gearbox.type"); req(s, "gearbox.ratios")
    req(s, "gearbox.finalDrive"); req(s, "clutch.maxTorque"); req(s, "fuel.tankL")
    req(s, "aero.cd"); req(s, "aero.frontalArea"); req(s, "geometry.wheelbase")

    local e = s.engine
    e.redlineRpm = e.redlineRpm or e.maxRpm
    if not e.torqueCurve then e.torqueCurve = Spec.synthTorqueCurve(e) end
    e.stallRpm = e.stallRpm or e.idleRpm * 0.45
    if not e.inertia then
        -- Rough rule: 0.10 kg m^2 per litre displacement + flywheel, min 0.12
        local disp = e.displacementL or 2.0
        e.inertia = math.max(0.12, 0.08 * disp + 0.06)
    end

    local w = s.wheels
    if not w.radius then
        w.radius = Spec.tyreRadius(req(s, "wheels.tyre"))
    end

    -- Derived convenience values
    s.derived = s.derived or {}
    local maxT, maxTrpm = 0.0, 0
    for _, p in ipairs(e.torqueCurve) do if p[2] > maxT then maxT, maxTrpm = p[2], p[1] end end
    s.derived.torquePeakNm, s.derived.torquePeakRpm = maxT, maxTrpm
    local bestP, bestPrpm = 0.0, 0
    for _, p in ipairs(e.torqueCurve) do
        local pw = p[2] * p[1] * Units.RADS_PER_RPM
        if pw > bestP then bestP, bestPrpm = pw, p[1] end
    end
    s.derived.powerPeakW, s.derived.powerPeakRpm = bestP, bestPrpm
    s.derived.powerPeakPS = Units.wToPs(bestP)
    s.derived.numGears = #s.gearbox.ratios
    s.derived.topGearRatio = s.gearbox.ratios[#s.gearbox.ratios] * s.gearbox.finalDrive
    -- Theoretical speed at redline in top gear [m/s]
    s.derived.vRedlineTop = e.redlineRpm * Units.RADS_PER_RPM / s.derived.topGearRatio * w.radius
    s.derived.powerToWeight = Units.wToKw(bestP) / (s.mass.curb / 1000.0) -- kW/t

    s.mass.frontAxleFraction = wmath.clamp(s.mass.frontAxleFraction, 0.3, 0.75)
    return s
end

WRP.Spec = Spec
return Spec
