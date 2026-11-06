--- wr_physics vehicle: longitudinal resistances and a simple traction limit.
-- Used by the offline simulator (tools/sim) and by the in-game coupling controller to decide
-- how much acceleration the game should produce for a given drivetrain output.
local Units = WRP.Units

local L = {}

--- Aerodynamic drag force [N] at speed v [m/s].
function L.dragForce(spec, v, rhoAir)
    rhoAir = rhoAir or Units.RHO_AIR_SEA_LEVEL
    return 0.5 * rhoAir * spec.aero.cd * spec.aero.frontalArea * v * v
end

--- Rolling resistance [N]. crr grows mildly with speed.
function L.rollingForce(spec, v, mass)
    mass = mass or spec.mass.curb
    local crr = spec.wheels.crr or 0.012
    local crrV = crr * (1.0 + v / 60.0)
    return crrV * mass * Units.G
end

--- Maximum tractive force the driven axle(s) can transmit [N] (static approximation).
-- Uses static weight distribution and a longitudinal load transfer estimate for accel a.
function L.tractionLimit(spec, mass, accel, mu)
    mu = mu or spec.wheels.muPeak or 1.0
    mass = mass or spec.mass.curb
    local wb = spec.geometry.wheelbase
    local h = spec.geometry.cgHeight
    local frontFrac = spec.mass.frontAxleFraction
    local wTotal = mass * Units.G
    local transfer = mass * accel * h / wb
    local wFront = wTotal * frontFrac - transfer
    local wRear = wTotal * (1.0 - frontFrac) + transfer
    local layout = spec.drivetrain.layout
    if layout == "FWD" then return mu * math.max(wFront, 0.0) end
    if layout == "RWD" then return mu * math.max(wRear, 0.0) end
    return mu * wTotal  -- AWD
end

--- Grade resistance [N] for slope angle theta (rad), positive uphill.
function L.gradeForce(mass, theta)
    return mass * Units.G * math.sin(theta)
end

WRP.Sim.Longitudinal = L
return L
