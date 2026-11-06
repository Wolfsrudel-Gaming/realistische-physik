--- wr_physics vehicle: first reference datasheets (phase 2/3 bootstrap).
--
-- Status "draft": values are from public manufacturer figures and period road tests, entered
-- from memory for the first driving tests. Each sheet must be reviewed and approved in the
-- web panel before it counts as reference data (F102). Please verify every number.
--
-- Real-world targets (for the automated measurement runs, F111):
--   acceleration0to100  seconds, published figure
--   topSpeedKmh         km/h
--   consumptionL100     combined l/100 km
local sheets = {}

-- Honda Civic Si Coupe (FG2), 2006, K20Z3 2.0 i-VTEC, 6MT, FWD
sheets.honda_civic_si_2006 = {
    id = "honda_civic_si_2006",
    name = "Honda Civic Si (FG2)", make = "Honda", year = 2006, market = "US",
    meta = { status = "draft", source = "manufacturer figures + road tests (from memory)" },
    mass = { curb = 1310, frontAxleFraction = 0.61 },
    engine = {
        code = "K20Z3", displacementL = 2.0, cylinders = 4, aspiration = "na",
        idleRpm = 750, maxRpm = 8200, redlineRpm = 8000,
        torquePeakNm = 188, torquePeakRpm = 6100,
        powerPeakW = 147000, powerPeakRpm = 7800,
        inertia = 0.16,
    },
    clutch = { maxTorque = 320 },
    gearbox = { type = "manual", ratios = { 3.267, 2.130, 1.517, 1.147, 0.921, 0.659 }, finalDrive = 4.765, reverse = 3.583 },
    drivetrain = { layout = "FWD" },
    wheels = { tyre = "215/45R17", muPeak = 1.0 },
    aero = { cd = 0.31, frontalArea = 2.1 },
    geometry = { wheelbase = 2.65, cgHeight = 0.50 },
    fuel = { type = "petrol", tankL = 50 },
    assist = { abs = true, esp = false, tcs = false },
    display = { units = "us", cluster = "digital_speedo_2006" },
    targets = { acceleration0to100 = 6.7, topSpeedKmh = 217, consumptionL100 = 8.4 },
    license = "B",
}

-- Toyota Corolla GT-S (AE86), 1985, 4A-GE 1.6, 5MT, RWD
sheets.toyota_ae86_1985 = {
    id = "toyota_ae86_1985",
    name = "Toyota Corolla GT-S (AE86)", make = "Toyota", year = 1985, market = "US",
    meta = { status = "draft", source = "manufacturer figures (from memory)" },
    mass = { curb = 1040, frontAxleFraction = 0.54 },
    engine = {
        code = "4A-GE", displacementL = 1.6, cylinders = 4, aspiration = "na",
        idleRpm = 850, maxRpm = 7700, redlineRpm = 7500,
        torquePeakNm = 131, torquePeakRpm = 4800,
        powerPeakW = 84000, powerPeakRpm = 6600,
        inertia = 0.14,
    },
    clutch = { maxTorque = 220 },
    gearbox = { type = "manual", ratios = { 3.587, 2.022, 1.384, 1.000, 0.861 }, finalDrive = 4.300, reverse = 3.484 },
    drivetrain = { layout = "RWD" },
    wheels = { tyre = "185/60R14", muPeak = 0.92 },
    aero = { cd = 0.39, frontalArea = 1.85 },
    geometry = { wheelbase = 2.40, cgHeight = 0.50 },
    fuel = { type = "petrol", tankL = 50 },
    assist = { abs = false, esp = false, tcs = false },
    display = { units = "us", cluster = "classic_analog" },
    targets = { acceleration0to100 = 8.9, topSpeedKmh = 190, consumptionL100 = 9.0 },
    license = "B",
}

-- Subaru Impreza WRX STI (GD), 2004, EJ257 2.5 turbo, 6MT, AWD
sheets.subaru_wrx_sti_2004 = {
    id = "subaru_wrx_sti_2004",
    name = "Subaru Impreza WRX STI (GD)", make = "Subaru", year = 2004, market = "US",
    meta = { status = "draft", source = "manufacturer figures (from memory)" },
    mass = { curb = 1470, frontAxleFraction = 0.58 },
    engine = {
        code = "EJ257", displacementL = 2.5, cylinders = 4, aspiration = "turbo",
        idleRpm = 800, maxRpm = 7200, redlineRpm = 7000,
        torquePeakNm = 407, torquePeakRpm = 4000,
        powerPeakW = 224000, powerPeakRpm = 6000,
        inertia = 0.19,
    },
    clutch = { maxTorque = 600 },
    gearbox = { type = "manual", ratios = { 3.636, 2.375, 1.761, 1.346, 0.971, 0.756 }, finalDrive = 3.900, reverse = 3.545 },
    drivetrain = { layout = "AWD" },
    wheels = { tyre = "225/45R17", muPeak = 1.02 },
    aero = { cd = 0.33, frontalArea = 2.05 },
    geometry = { wheelbase = 2.53, cgHeight = 0.52 },
    fuel = { type = "petrol", tankL = 60 },
    assist = { abs = true, esp = false, tcs = false },
    display = { units = "us", cluster = "modern_analog" },
    targets = { acceleration0to100 = 5.2, topSpeedKmh = 250, consumptionL100 = 12.4 },
    license = "B",
}

-- Ford Mustang GT, 2011, 5.0 Coyote V8, 6MT (MT-82), RWD
sheets.ford_mustang_gt_2011 = {
    id = "ford_mustang_gt_2011",
    name = "Ford Mustang GT (S197)", make = "Ford", year = 2011, market = "US",
    meta = { status = "draft", source = "manufacturer figures (from memory)" },
    mass = { curb = 1650, frontAxleFraction = 0.54 },
    engine = {
        code = "Coyote 5.0", displacementL = 5.0, cylinders = 8, aspiration = "na",
        idleRpm = 650, maxRpm = 7000, redlineRpm = 6800,
        torquePeakNm = 529, torquePeakRpm = 4250,
        powerPeakW = 307000, powerPeakRpm = 6500,
        inertia = 0.30,
    },
    clutch = { maxTorque = 800 },
    gearbox = { type = "manual", ratios = { 3.657, 2.430, 1.686, 1.320, 1.000, 0.651 }, finalDrive = 3.310, reverse = 3.380 },
    drivetrain = { layout = "RWD" },
    wheels = { tyre = "235/50R18", muPeak = 1.0 },
    aero = { cd = 0.37, frontalArea = 2.25 },
    geometry = { wheelbase = 2.72, cgHeight = 0.53 },
    fuel = { type = "petrol", tankL = 61 },
    assist = { abs = true, esp = true, tcs = true },
    display = { units = "us", cluster = "modern_analog" },
    targets = { acceleration0to100 = 4.8, topSpeedKmh = 250, consumptionL100 = 11.8 },
    license = "B",
}

-- Toyota Camry LE 2.4 (XV40), 2007, 2AZ-FE, 5AT, FWD
sheets.toyota_camry_2007 = {
    id = "toyota_camry_2007",
    name = "Toyota Camry LE 2.4 (XV40)", make = "Toyota", year = 2007, market = "US",
    meta = { status = "draft", source = "manufacturer figures (from memory)" },
    mass = { curb = 1490, frontAxleFraction = 0.60 },
    engine = {
        code = "2AZ-FE", displacementL = 2.4, cylinders = 4, aspiration = "na",
        idleRpm = 700, maxRpm = 6500, redlineRpm = 6300,
        torquePeakNm = 218, torquePeakRpm = 4000,
        powerPeakW = 118000, powerPeakRpm = 6000,
        inertia = 0.18,
    },
    clutch = { maxTorque = 400 },   -- torque converter capacity
    gearbox = { type = "automatic", ratios = { 3.943, 2.197, 1.413, 1.020, 0.713 }, finalDrive = 3.391, reverse = 3.145, shiftTime = 0.5 },
    drivetrain = { layout = "FWD" },
    wheels = { tyre = "215/60R16", muPeak = 0.95 },
    aero = { cd = 0.28, frontalArea = 2.25 },
    geometry = { wheelbase = 2.78, cgHeight = 0.54 },
    fuel = { type = "petrol", tankL = 70 },
    assist = { abs = true, esp = false, tcs = false },
    display = { units = "us", cluster = "modern_analog" },
    targets = { acceleration0to100 = 9.0, topSpeedKmh = 200, consumptionL100 = 9.0 },
    license = "B",
}

--- Vanilla model -> datasheet id (F10). Model names as in GTA (lowercase).
local vanillaMap = {
    blista = "honda_civic_si_2006",
    futo = "toyota_ae86_1985",
    sultan = "subaru_wrx_sti_2004",
    dominator = "ford_mustang_gt_2011",
    premier = "toyota_camry_2007",
}

WRP.VehicleData = WRP.VehicleData or {}
WRP.VehicleData.sheets = sheets
WRP.VehicleData.vanillaMap = vanillaMap
return { sheets = sheets, vanillaMap = vanillaMap }
