--- wr_physics vehicle: class fallback datasheets (F132).
-- Used when a model has no approved datasheet. Keyed by GTA vehicle class id
-- (GetVehicleClass): 0 Compacts, 1 Sedans, 2 SUVs, 3 Coupes, 4 Muscle, 5 Sports Classics,
-- 6 Sports, 7 Super, 8 Motorcycles, 9 Off-road, 10 Industrial, 11 Utility, 12 Vans,
-- 13 Cycles, 14 Boats, 15 Helicopters, 16 Planes, 17 Service, 18 Emergency, 19 Military,
-- 20 Commercial, 21 Trains, 22 Open Wheel.
local Classes = {}

local function car(o)
    return {
        name = o.name,
        meta = { status = "draft", source = "class-fallback" },
        year = o.year or 2010,
        mass = { curb = o.mass, frontAxleFraction = o.front or 0.6 },
        engine = {
            displacementL = o.disp, aspiration = o.aspiration or "na",
            idleRpm = o.idle or 800, maxRpm = o.maxRpm, redlineRpm = o.maxRpm - 200,
            torquePeakNm = o.torque, torquePeakRpm = o.torqueRpm,
            powerPeakW = o.powerKw * 1000.0, powerPeakRpm = o.powerRpm,
        },
        clutch = { maxTorque = o.torque * 1.6 },
        gearbox = { type = o.gearbox or "automatic", ratios = o.ratios, finalDrive = o.final, reverse = 3.4 },
        drivetrain = { layout = o.layout or "FWD" },
        wheels = { tyre = o.tyre },
        aero = { cd = o.cd, frontalArea = o.area },
        geometry = { wheelbase = o.wb, cgHeight = o.cg or 0.52 },
        fuel = { type = o.fuel or "petrol", tankL = o.tank },
        display = { cluster = o.cluster or "modern_analog" },
    }
end

Classes.byClassId = {
    [0] = car { name = "Compact (class)", mass = 1150, disp = 1.4, maxRpm = 6400, torque = 150, torqueRpm = 3800,
        powerKw = 70, powerRpm = 5800, ratios = { 3.77, 2.05, 1.32, 0.95, 0.76 }, final = 4.1,
        tyre = "185/60R15", cd = 0.32, area = 2.05, wb = 2.5, tank = 45, gearbox = "manual" },
    [1] = car { name = "Sedan (class)", mass = 1500, disp = 2.4, maxRpm = 6300, torque = 220, torqueRpm = 4000,
        powerKw = 118, powerRpm = 6000, ratios = { 3.94, 2.2, 1.41, 1.02, 0.71 }, final = 3.39,
        tyre = "215/60R16", cd = 0.29, area = 2.25, wb = 2.78, tank = 65 },
    [2] = car { name = "SUV (class)", mass = 2100, disp = 3.5, maxRpm = 6200, torque = 350, torqueRpm = 4500,
        powerKw = 200, powerRpm = 6000, ratios = { 4.58, 2.96, 1.91, 1.45, 1.0, 0.75 }, final = 3.73,
        tyre = "265/60R18", cd = 0.36, area = 2.9, wb = 2.9, tank = 85, layout = "AWD", cg = 0.68 },
    [3] = car { name = "Coupe (class)", mass = 1550, disp = 3.0, maxRpm = 6800, torque = 300, torqueRpm = 4200,
        powerKw = 180, powerRpm = 6200, ratios = { 4.17, 2.34, 1.52, 1.14, 0.87, 0.69 }, final = 3.46,
        tyre = "225/45R18", cd = 0.30, area = 2.15, wb = 2.76, tank = 60, layout = "RWD" },
    [4] = car { name = "Muscle (class)", mass = 1700, disp = 5.7, maxRpm = 6000, torque = 540, torqueRpm = 4200,
        powerKw = 310, powerRpm = 5700, ratios = { 2.97, 2.07, 1.43, 1.0, 0.84, 0.56 }, final = 3.55,
        tyre = "245/45R20", cd = 0.37, area = 2.3, wb = 2.95, tank = 70, layout = "RWD", gearbox = "manual",
        cluster = "classic_analog", year = 1970, front = 0.55 },
    [5] = car { name = "Sports Classic (class)", mass = 1250, disp = 3.0, maxRpm = 6500, torque = 240, torqueRpm = 4500,
        powerKw = 130, powerRpm = 6000, ratios = { 3.2, 2.0, 1.4, 1.0, 0.82 }, final = 3.9,
        tyre = "205/55R16", cd = 0.38, area = 1.9, wb = 2.4, tank = 60, layout = "RWD", gearbox = "manual",
        cluster = "vintage", year = 1968 },
    [6] = car { name = "Sports (class)", mass = 1450, disp = 3.0, aspiration = "turbo", maxRpm = 7000, torque = 450,
        torqueRpm = 2500, powerKw = 260, powerRpm = 6000, ratios = { 4.05, 2.4, 1.58, 1.19, 1.0, 0.84, 0.67 },
        final = 3.15, tyre = "245/40R19", cd = 0.31, area = 2.1, wb = 2.7, tank = 64, layout = "RWD",
        gearbox = "dct", cluster = "digital" },
    [7] = car { name = "Super (class)", mass = 1500, disp = 4.0, aspiration = "turbo", maxRpm = 8000, torque = 700,
        torqueRpm = 3000, powerKw = 480, powerRpm = 7500, ratios = { 3.08, 2.19, 1.63, 1.29, 1.03, 0.84, 0.62 },
        final = 3.55, tyre = "305/30R20", cd = 0.34, area = 2.0, wb = 2.65, tank = 72, layout = "RWD",
        gearbox = "dct", cluster = "digital", cg = 0.42, front = 0.42 },
    [9] = car { name = "Off-road (class)", mass = 2000, disp = 3.6, maxRpm = 6400, torque = 350, torqueRpm = 4300,
        powerKw = 210, powerRpm = 6000, ratios = { 4.71, 3.14, 2.1, 1.67, 1.29, 1.0, 0.84, 0.67 }, final = 3.73,
        tyre = "285/70R17", cd = 0.45, area = 3.0, wb = 2.95, tank = 80, layout = "AWD", cg = 0.72 },
    [12] = car { name = "Van (class)", mass = 2200, disp = 2.0, fuel = "diesel", maxRpm = 4500, torque = 360,
        torqueRpm = 1800, powerKw = 120, powerRpm = 3800, aspiration = "turbo", idle = 750,
        ratios = { 5.08, 2.95, 1.83, 1.29, 1.0, 0.8 }, final = 3.9, tyre = "235/65R16", cd = 0.35, area = 3.6,
        wb = 3.6, tank = 75, gearbox = "manual", cg = 0.75 },
    [20] = car { name = "Commercial (class)", mass = 7500, disp = 7.7, fuel = "diesel", maxRpm = 2500, torque = 1400,
        torqueRpm = 1200, powerKw = 240, powerRpm = 2200, aspiration = "turbo", idle = 600,
        ratios = { 11.32, 9.14, 7.2, 5.79, 4.46, 3.64, 2.98, 2.37, 1.86, 1.5, 1.2, 1.0 }, final = 3.08,
        tyre = "315/80R22.5", cd = 0.6, area = 8.5, wb = 4.5, tank = 400, layout = "RWD", gearbox = "automatic",
        cluster = "truck", cg = 1.1, front = 0.5 },
}
-- Aliases
Classes.byClassId[10] = Classes.byClassId[20]  -- Industrial
Classes.byClassId[11] = Classes.byClassId[12]  -- Utility
Classes.byClassId[17] = Classes.byClassId[12]  -- Service
Classes.byClassId[18] = Classes.byClassId[1]   -- Emergency
Classes.byClassId[19] = Classes.byClassId[9]   -- Military

function Classes.forClass(classId)
    return Classes.byClassId[classId] or Classes.byClassId[1]
end

WRP.SpecClasses = Classes
return Classes
