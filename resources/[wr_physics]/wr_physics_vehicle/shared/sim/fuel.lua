--- wr_physics vehicle: fuel consumption, phase 3a v0 (combustion only; EV in a later step).
--
-- Fuel mass flow = BSFC(rpm, load) * P_brake / 3.6e6  [g/s] with BSFC in g/kWh.
-- v0 uses a BSFC curve over load with a mild rpm penalty; a full 2D map can be supplied
-- in the datasheet later (fuel.bsfcMap).
-- Idle: fixed idle flow [l/h]. Overrun (closed throttle, engine braking): fuel cut.
--
-- World scale (F127): distance-dependent consumption is multiplied by world scale k while the
-- vehicle is moving; idle burn is time-based and not scaled.
local wmath = WRP.Math
local Units = WRP.Units
local class = WRP.class

local Fuel = class("Fuel")

function Fuel:init(f, worldScale)
    self.spec = f
    self.type = f.type or "petrol"
    self.density = Units.FUEL_DENSITY[self.type] or 0.745   -- kg/l
    self.tankL = f.tankL
    self.levelL = f.initialL or f.tankL
    self.bsfcMin = f.bsfcMin or 240.0        -- g/kWh at best efficiency (~75% load)
    self.bsfcIdleFactor = f.bsfcIdleFactor or 2.6
    self.idleFlowLh = f.idleFlowLh or 0.7
    self.worldScale = worldScale or 1.0
    self.flowLh = 0.0                        -- current flow l/h (unscaled, for display)
    self.consumedL = 0.0
end

--- BSFC in g/kWh for a load fraction (0..1) and rpm.
function Fuel:bsfc(load, rpm, maxRpm)
    -- Efficiency is best around 70-80% load, worse at low load and at very high rpm.
    local loadPenalty = 1.0 + (1.0 - wmath.clamp(load / 0.75, 0.0, 1.0)) ^ 2 * (self.bsfcIdleFactor - 1.0)
    local rpmFrac = wmath.clamp(rpm / math.max(maxRpm, 1.0), 0.0, 1.0)
    local rpmPenalty = 1.0 + math.max(0.0, rpmFrac - 0.6) * 0.5
    return self.bsfcMin * loadPenalty * rpmPenalty
end

--- Advance consumption.
-- @param dt seconds
-- @param engine Engine instance (uses rpm, throttleEff, torque, running, maxRpm)
-- @param moving boolean, vehicle speed above threshold
-- @return litres consumed this step
function Fuel:step(dt, engine, moving)
    local flowLh = 0.0
    if engine.running then
        local rpm = engine:rpm()
        local torque = engine.torque
        if torque > 0.0 and engine.throttleEff > 0.0 then
            local pW = torque * rpm * Units.RADS_PER_RPM
            local load = wmath.clamp(torque / math.max(engine:wotTorque(rpm), 1.0), 0.0, 1.0)
            local gPerS = self:bsfc(load, rpm, engine.maxRpm) * (pW / 1000.0) / 3600.0
            flowLh = gPerS / (self.density * 1000.0) * 3600.0
            flowLh = math.max(flowLh, self.idleFlowLh)
        elseif engine.throttleEff > 0.0 or engine.idleCtrl > 0.0 then
            flowLh = self.idleFlowLh
        else
            flowLh = 0.0  -- overrun fuel cut
        end
    end
    self.flowLh = flowLh
    local scale = moving and self.worldScale or 1.0
    local litres = flowLh / 3600.0 * dt * scale
    litres = math.min(litres, self.levelL)
    self.levelL = self.levelL - litres
    self.consumedL = self.consumedL + litres
    if self.levelL <= 0.0 then self.levelL = 0.0 end
    return litres
end

function Fuel:isEmpty() return self.levelL <= 0.0 end
function Fuel:fraction() return self.tankL > 0 and self.levelL / self.tankL or 0.0 end

WRP.Sim.Fuel = Fuel
return Fuel
