--- wr_physics vehicle: internal combustion engine model (phase 3a, v0).
--
-- Model summary
--   * Brake torque at wide-open throttle comes from the datasheet torque curve.
--   * Closed-throttle friction (engine braking) is a + b*rpm/1000 [Nm].
--   * Net indicated torque = throttle * T_wot(rpm) - (1 - throttle) * T_fric(rpm).
--   * Idle speed controller raises effective throttle when rpm drops below idle.
--   * Rev limiter cuts fuel above maxRpm (soft cut).
--   * Stall when rpm drops below stallRpm while running.
--   * Starter cranks the engine to crankRpm; it fires once rpm >= fireRpm.
--   * Thermal model is a placeholder (coolant warms toward 90 degC); full thermics come later.
--
-- Pure Lua: no natives. All units SI (rad/s internally, rpm at the API boundary for readability).
local wmath = WRP.Math
local Curve = WRP.Curve
local Units = WRP.Units
local class = WRP.class

local Engine = class("Engine")

local RPM = Units.RADS_PER_RPM

--- @param e datasheet.engine table (already resolved by Spec)
function Engine:init(e)
    self.spec = e
    self.torqueCurve = Curve.new(e.torqueCurve)
    self.idleRpm = e.idleRpm
    self.maxRpm = e.maxRpm            -- limiter
    self.stallRpm = e.stallRpm or (e.idleRpm * 0.45)
    self.inertia = e.inertia          -- kg m^2 (crank + flywheel + clutch)
    self.fricA = e.friction.a         -- Nm
    self.fricB = e.friction.b         -- Nm per 1000 rpm
    self.starterTorque = e.starterTorque or 60.0
    self.crankRpm = e.crankRpm or 250.0
    self.fireRpm = e.fireRpm or 200.0

    self.omega = 0.0                  -- rad/s
    self.running = false
    self.cranking = false
    self.limiterActive = false
    self.throttleEff = 0.0
    self.torque = 0.0                 -- last net torque produced [Nm]
    self.coolantK = Units.cToK(20.0)  -- placeholder thermal state
    self.idleCtrl = 0.0
    self.fireTimer = 0.0              -- grace period after firing before the stall check applies
end

function Engine:rpm() return self.omega / RPM end
function Engine:setRpm(rpm) self.omega = rpm * RPM end

--- Wide-open-throttle brake torque at rpm.
function Engine:wotTorque(rpm) return self.torqueCurve:at(rpm) end

--- Closed-throttle friction torque at rpm (positive number).
function Engine:frictionTorque(rpm) return self.fricA + self.fricB * rpm / 1000.0 end

--- Power at the crank for a given rpm and throttle [W].
function Engine:power(rpm, throttle)
    local t = throttle * self:wotTorque(rpm) - (1.0 - throttle) * self:frictionTorque(rpm)
    return t * rpm * RPM
end

--- Peak power [W] and the rpm where it occurs (scans the curve domain).
function Engine:peakPower()
    local lo, hi = self.torqueCurve:domain()
    local best, bestRpm = 0.0, lo
    for rpm = lo, hi, 50 do
        local p = self:wotTorque(rpm) * rpm * RPM
        if p > best then best, bestRpm = p, rpm end
    end
    return best, bestRpm
end

function Engine:startCranking() if not self.running then self.cranking = true end end
function Engine:stopCranking() self.cranking = false end
function Engine:shutOff() self.running = false; self.cranking = false end

--- Force the engine into a running state at idle (e.g. when a vehicle spawns with engine on).
function Engine:forceRunning()
    self.running = true
    self.cranking = false
    if self.omega < self.idleRpm * RPM then self:setRpm(self.idleRpm) end
end

--- Advance the engine by dt.
-- @param dt seconds
-- @param throttle 0..1 driver demand
-- @param loadTorque Nm resisting torque applied at the crank by the clutch (positive = slows engine)
-- @return netTorque Nm produced by the engine this step (before the load)
function Engine:step(dt, throttle, loadTorque)
    throttle = wmath.clamp(throttle or 0.0, 0.0, 1.0)
    loadTorque = loadTorque or 0.0
    local rpm = self:rpm()
    local torque

    if self.running then
        -- Idle speed control: a simple proportional governor that opens the throttle a little
        -- when rpm sags below idle. Band of 300 rpm, max authority 0.35.
        local idleErr = (self.idleRpm - rpm) / 300.0
        self.idleCtrl = wmath.clamp(idleErr, 0.0, 0.35)
        local thr = math.max(throttle, self.idleCtrl)

        -- Rev limiter (fuel cut). Hysteresis: cuts at maxRpm, releases 150 rpm below.
        if rpm >= self.maxRpm then self.limiterActive = true end
        if self.limiterActive and rpm < self.maxRpm - 150.0 then self.limiterActive = false end
        if self.limiterActive then thr = 0.0 end

        self.throttleEff = thr
        torque = thr * self:wotTorque(rpm) - (1.0 - thr) * self:frictionTorque(rpm)
    elseif self.cranking then
        self.throttleEff = 0.0
        -- Starter motor drives the crank against friction.
        torque = self.starterTorque - self:frictionTorque(rpm)
        if rpm >= self.fireRpm then
            -- Engine fires: hand over to the running branch next step. The idle governor
            -- has up to 2 s to pull the engine up before the stall check applies.
            self.running = true
            self.cranking = false
            self.fireTimer = 2.0
        end
    else
        self.throttleEff = 0.0
        torque = -self:frictionTorque(rpm)
    end

    local alpha = (torque - loadTorque) / self.inertia
    self.omega = math.max(0.0, self.omega + alpha * dt)
    rpm = self:rpm()

    if self.fireTimer > 0.0 then
        self.fireTimer = self.fireTimer - dt
        if rpm >= self.idleRpm * 0.8 then self.fireTimer = 0.0 end
    elseif self.running and rpm < self.stallRpm then
        self.running = false
    end

    -- Placeholder thermal behaviour so instruments show something sensible.
    local target = self.running and Units.cToK(90.0) or Units.cToK(20.0)
    local tau = self.running and 240.0 or 1200.0
    self.coolantK = wmath.lowpass(self.coolantK, target, dt, tau)

    self.torque = torque
    return torque
end

WRP.Sim = WRP.Sim or {}
WRP.Sim.Engine = Engine
return Engine
