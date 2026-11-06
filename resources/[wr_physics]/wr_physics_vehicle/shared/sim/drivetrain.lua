--- wr_physics vehicle: drivetrain = engine + clutch/torque converter + gearbox, phase 3a v0.
--
-- The wheels belong to the game engine (or to the offline simulator), so the drivetrain
-- receives the wheel-side speed as an input and returns the torque it delivers to the wheels.
--
-- Clutch model (manual):
--   capacity = maxTorque * engagement (engagement = 1 - pedal)
--   locked   : engine speed follows the gearbox input speed, engine torque minus the inertia
--              reaction goes to the wheels.
--   slipping : Coulomb friction, torque = capacity * sign(slip).
-- Torque converter (automatic/DCT):
--   engagement rises with engine speed above idle (creep at idle, firm coupling above ~1800 rpm);
--   handled as a clutch with speed-dependent capacity. Good enough for v0; a proper K-factor
--   converter comes with phase 3a refinement.
local wmath = WRP.Math
local Units = WRP.Units
local class = WRP.class
local Engine = WRP.Sim.Engine
local Gearbox = WRP.Sim.Gearbox

local Drivetrain = class("Drivetrain")

local RPM = Units.RADS_PER_RPM

function Drivetrain:init(spec)
    self.spec = spec
    self.engine = Engine.new(spec.engine)
    self.gearbox = Gearbox.new(spec.gearbox, spec.engine)
    self.clutchMaxTorque = spec.clutch.maxTorque
    self.lockSlipRadS = (spec.clutch.lockSlipRpm or 60.0) * RPM
    self.wheelRadius = spec.wheels.radius

    self.clutchPedal = 0.0       -- 0 = released (engaged), 1 = fully pressed (disengaged)
    self.clutchEngagement = 1.0
    self.clutchLocked = false
    self.clutchTorque = 0.0      -- Nm transmitted (crank side)
    self.wheelTorque = 0.0       -- Nm at the driven wheels (sum)
    self.wheelForce = 0.0        -- N tractive force (sum)
    self.inputRadS = 0.0
    self.stalled = false
    self.prevInputRadS = 0.0
end

--- Wheel-side angular speed from vehicle speed.
function Drivetrain:wheelRadSFromSpeed(v) return v / self.wheelRadius end

--- Effective clutch engagement 0..1.
function Drivetrain:computeEngagement()
    if self.gearbox:isManual() then
        return wmath.clamp(1.0 - self.clutchPedal, 0.0, 1.0)
    end
    -- Torque converter approximation: creep from idle, coupled above idle + 1400 rpm.
    local rpm = self.engine:rpm()
    local idle = self.engine.idleRpm
    return wmath.clamp(0.08 + 0.92 * wmath.invLerp(idle - 100.0, idle + 1400.0, rpm), 0.0, 1.0)
end

--- Advance the drivetrain.
-- @param dt seconds
-- @param throttle 0..1
-- @param clutchPedal 0..1 (manual only; ignored for automatics)
-- @param wheelRadS average angular speed of the driven wheels (rad/s, signed)
-- @param vehicleSpeed m/s signed
-- @return wheelTorque Nm (sum over driven wheels), engineRpm
function Drivetrain:step(dt, throttle, clutchPedal, wheelRadS, vehicleSpeed)
    self.clutchPedal = clutchPedal or 0.0
    local gb, eng = self.gearbox, self.engine

    gb:step(dt, eng:rpm(), throttle, wheelRadS, vehicleSpeed)
    local ratio = gb:totalRatio()
    local inputRadS = wheelRadS * ratio       -- gearbox input (clutch) speed
    self.inputRadS = inputRadS

    local engagement = self:computeEngagement()
    if ratio == 0.0 then engagement = 0.0 end
    self.clutchEngagement = engagement
    local capacity = self.clutchMaxTorque * engagement

    local slip = eng.omega - inputRadS
    local clutchTorque

    -- Lock decision
    if capacity <= 0.0 then
        self.clutchLocked = false
    elseif not self.clutchLocked then
        if math.abs(slip) < self.lockSlipRadS and engagement > 0.9 then self.clutchLocked = true end
    end

    if self.clutchLocked then
        -- Kinematic lock: the engine runs at input speed. Torque through the clutch equals the
        -- engine's net torque minus what is needed to accelerate the engine inertia with the input.
        local inputAlpha = (inputRadS - self.prevInputRadS) / dt
        local engTorque = eng:step(dt, throttle, 0.0)       -- compute torque at current state
        clutchTorque = engTorque - eng.inertia * inputAlpha
        if math.abs(clutchTorque) > capacity then
            -- Overload: break lock and fall back to slipping this step.
            self.clutchLocked = false
            clutchTorque = capacity * wmath.sign(clutchTorque)
            -- engine already stepped with zero load; apply the load correction
            eng.omega = math.max(0.0, eng.omega - clutchTorque / eng.inertia * dt)
        else
            eng.omega = math.max(0.0, inputRadS)
            if eng.running and eng:rpm() < eng.stallRpm then eng.running = false end
        end
    else
        clutchTorque = capacity * wmath.sign(slip)
        -- Damp the Coulomb switching near zero slip to avoid chatter.
        local soft = wmath.clamp(math.abs(slip) / (self.lockSlipRadS * 0.5), 0.0, 1.0)
        clutchTorque = clutchTorque * soft
        eng:step(dt, throttle, clutchTorque)
    end

    self.prevInputRadS = inputRadS
    self.clutchTorque = clutchTorque
    self.stalled = not eng.running and not eng.cranking

    local wheelTorque = clutchTorque * ratio * gb.efficiency
    -- Reverse ratio is negative, which flips the torque sign as it should.
    self.wheelTorque = wheelTorque
    self.wheelForce = wheelTorque / self.wheelRadius
    return wheelTorque, eng:rpm()
end

--- Convenience: snapshot of the state for telemetry / state bags.
function Drivetrain:snapshot()
    local gb, eng = self.gearbox, self.engine
    return {
        rpm = eng:rpm(),
        running = eng.running,
        cranking = eng.cranking,
        limiter = eng.limiterActive,
        gear = gb.gear,
        targetGear = gb.targetGear,
        shifting = gb:isShifting(),
        lever = gb.lever,
        clutch = self.clutchEngagement,
        clutchLocked = self.clutchLocked,
        clutchTorque = self.clutchTorque,
        engineTorque = eng.torque,
        wheelTorque = self.wheelTorque,
        wheelForce = self.wheelForce,
        coolantC = Units.kToC(eng.coolantK),
    }
end

WRP.Sim.Drivetrain = Drivetrain
return Drivetrain
