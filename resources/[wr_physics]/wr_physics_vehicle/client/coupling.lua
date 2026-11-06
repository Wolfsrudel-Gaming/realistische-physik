--- wr_physics vehicle (client): coupling between the simulation and the game's drive physics.
--
-- This is spike S1/S2 made usable. The simulation knows the tractive force the drivetrain
-- delivers; the game owns wheels, tyres, suspension and collisions. Three strategies
-- (Config.vehicle.coupling):
--   power  : per-frame torque multiplier on the game's engine (SetVehicleCheatPowerIncrease).
--            Keeps the game's wheelspin behaviour. Cannot push in reverse or with closed throttle.
--   force  : apply the simulated force directly to the chassis (ApplyForceToEntity).
--            Exact but bypasses tyre slip; mainly for measurements.
--   hybrid : power path with a PI controller on longitudinal acceleration, force path only where
--            the power path cannot act (engine braking, reverse, creep, throttle closed).
--
-- Acceleration target: a_des = (F_wheel - F_drag - F_roll) / m_spec, i.e. the simulation
-- defines the complete longitudinal dynamics and the game is driven to match it.
local wmath = WRP.Math
local Units = WRP.Units
local Config = WRP.Config
local Long = WRP.Sim.Longitudinal
local class = WRP.class

local Coupling = class("Coupling")

function Coupling:init(veh, spec)
    self.veh = veh
    self.spec = spec
    self.mass = spec.mass.curb
    self.mode = Config.vehicle.coupling
    self.pi = wmath.newPI(0.35, 0.9, -3.0, Config.vehicle.powerMultMax, 4.0)
    self.vPrev = 0.0
    self.aMeas = 0.0
    self.aDes = 0.0
    self.mult = 1.0
    self.residualN = 0.0
    self.gtaDriveForce = GetVehicleHandlingFloat(veh, "CHandlingData", "fInitialDriveForce") or 0.25
    self.gtaMass = GetVehicleHandlingFloat(veh, "CHandlingData", "fMass") or self.mass
    self.forceType = 0
    self.forceScale = 1.0
end

function Coupling:setMode(mode)
    self.mode = mode
    self.pi:reset()
end

--- Longitudinal speed of the vehicle along its own axis [m/s], signed.
function Coupling:forwardSpeed()
    return GetEntitySpeedVector(self.veh, true).y
end

--- Apply the coupling for this frame.
-- @param dt frame time
-- @param wheelForce N from the drivetrain (sum over driven wheels), signed
-- @param inputs sampled driver inputs
-- @param engineRunning boolean
function Coupling:step(dt, wheelForce, inputs, engineRunning)
    local veh = self.veh
    local v = self:forwardSpeed()
    local aRaw = (v - self.vPrev) / math.max(dt, 1e-3)
    self.vPrev = v
    self.aMeas = wmath.lowpass(self.aMeas, aRaw, dt, 0.08)

    local sign = v >= 0 and 1 or -1
    local fRes = Long.dragForce(self.spec, math.abs(v), Config.world.airDensity) + Long.rollingForce(self.spec, math.abs(v), self.mass)
    self.aDes = (wheelForce - sign * fRes) / self.mass

    local braking = inputs.brake > 0.05 or inputs.handbrake
    local throttleOpen = inputs.throttle > 0.02

    -- Power path --------------------------------------------------------------------------
    local usePower = (self.mode == "power" or self.mode == "hybrid") and engineRunning and throttleOpen
        and wheelForce > 0 and v >= -0.5 and not braking
    if usePower then
        -- Feed-forward: the game's full-throttle drive force is roughly fInitialDriveForce * m * g.
        local fGta = math.max(self.gtaDriveForce * self.gtaMass * Units.G * inputs.throttle, 50.0)
        local ff = wheelForce / fGta
        local corr = self.pi:step(self.aDes - self.aMeas, dt)
        self.mult = wmath.clamp(ff + corr, 0.0, Config.vehicle.powerMultMax)
        SetVehicleCheatPowerIncrease(veh, self.mult)
    else
        self.pi:reset()
        self.mult = 0.0
        if self.mode ~= "force" then SetVehicleCheatPowerIncrease(veh, 0.0) end
    end

    -- Force path --------------------------------------------------------------------------
    local useForce = false
    if self.mode == "force" then
        useForce = not braking
    elseif self.mode == "hybrid" then
        -- Where the power path cannot act: closed throttle (engine braking/creep), reverse gear
        -- torque, or engine off. Not while the driver brakes (the game's brakes are authoritative).
        useForce = not braking and not usePower and (wheelForce ~= 0.0 or math.abs(v) > 0.3)
    end
    if useForce then
        local errA = self.aDes - self.aMeas
        local f = errA * self.mass
        local maxF = Config.vehicle.residualForceMaxG * self.mass * Units.G
        f = wmath.clamp(f, -maxF, maxF)
        -- Do not pull a stationary car backwards from engine braking alone.
        if wheelForce >= 0.0 and f < 0.0 and math.abs(v) < 0.3 then f = 0.0 end
        self.residualN = f
        if math.abs(f) > 5.0 then
            ApplyForceToEntity(veh, self.forceType, 0.0, f * self.forceScale * dt, 0.0, 0.0, 0.0, 0.0, 0, true, true, true, false, true)
        end
    else
        self.residualN = 0.0
    end
end

--- Release all per-frame overrides (call when leaving the vehicle).
function Coupling:release()
    SetVehicleCheatPowerIncrease(self.veh, 1.0)
end

WRP.VehicleCoupling = Coupling
