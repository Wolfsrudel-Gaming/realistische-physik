--- wr_physics vehicle: gearbox (manual / automatic / dual-clutch), phase 3a v0.
--
-- Gear numbering: -1 = reverse, 0 = neutral, 1..n = forward.
-- Manual:    driver requests shifts; a shift takes shiftTime during which the box is in neutral.
-- Automatic: shift logic from rpm and throttle, kickdown, P/R/N/D lever; torque converter
--            is approximated in Drivetrain (not here).
-- DCT:       automatic logic with very short torque interruption.
local wmath = WRP.Math
local class = WRP.class

local Gearbox = class("Gearbox")

Gearbox.TYPE_MANUAL = "manual"
Gearbox.TYPE_AUTOMATIC = "automatic"
Gearbox.TYPE_DCT = "dct"

function Gearbox:init(g, engineSpec)
    self.spec = g
    self.type = g.type
    self.ratios = g.ratios            -- forward ratios, index 1..n
    self.reverseRatio = g.reverse
    self.finalDrive = g.finalDrive
    self.efficiency = g.efficiency or 0.92
    self.shiftTime = g.shiftTime or (self.type == Gearbox.TYPE_DCT and 0.12 or (self.type == Gearbox.TYPE_AUTOMATIC and 0.45 or 0.0))
    self.numGears = #g.ratios

    self.gear = 0                     -- current engaged gear
    self.targetGear = 0
    self.shiftTimer = 0.0             -- >0 while shifting
    self.lever = (self.type == Gearbox.TYPE_MANUAL) and "M" or "P"   -- P R N D M for autos
    self.shiftingUp = false

    -- Automatic shift map derived from the engine spec.
    self.idleRpm = engineSpec.idleRpm
    self.maxRpm = engineSpec.maxRpm
    self.upshiftMin = g.upshiftRpmMin or (engineSpec.idleRpm + 1200)
    self.upshiftMax = g.upshiftRpmMax or (engineSpec.maxRpm - 250)
    self.downshiftMin = g.downshiftRpmMin or (engineSpec.idleRpm + 300)
    self.downshiftMax = g.downshiftRpmMax or (engineSpec.idleRpm + 2200)
    self.autoHoldTimer = 0.0
end

function Gearbox:isShifting() return self.shiftTimer > 0.0 end
function Gearbox:isManual() return self.type == Gearbox.TYPE_MANUAL end

--- Total ratio engine -> wheels for the currently engaged gear (0 in neutral/shift).
function Gearbox:totalRatio(gear)
    gear = gear or self.gear
    if self.shiftTimer > 0.0 and gear == self.gear then return 0.0 end
    if gear == 0 then return 0.0 end
    if gear < 0 then return -self.reverseRatio * self.finalDrive end
    local r = self.ratios[gear]
    if not r then return 0.0 end
    return r * self.finalDrive
end

--- Begin a shift to `gear`. Returns true if accepted.
function Gearbox:requestGear(gear)
    if gear < -1 or gear > self.numGears then return false end
    if gear == self.gear and self.shiftTimer <= 0.0 then return false end
    self.targetGear = gear
    self.shiftingUp = gear > self.gear
    if self.shiftTime > 0.0 then
        self.shiftTimer = self.shiftTime
    else
        self.gear = gear
    end
    return true
end

function Gearbox:shiftUp()
    if self.gear < self.numGears then return self:requestGear(self.gear + 1) end
    return false
end

function Gearbox:shiftDown()
    if self.gear > -1 then return self:requestGear(self.gear - 1) end
    return false
end

--- Automatic lever: "P", "R", "N", "D" (also "M" for manual mode on autos; stays in D logic).
function Gearbox:setLever(lever)
    if self:isManual() then return end
    self.lever = lever
    if lever == "P" or lever == "N" then
        self:requestGear(0)
    elseif lever == "R" then
        self:requestGear(-1)
    elseif lever == "D" then
        if self.gear <= 0 then self:requestGear(1) end
    end
end

--- Engine rpm that would result in `gear` at the given output (wheel-side) speed.
function Gearbox:rpmInGear(gear, outputRadS)
    local r = gear < 0 and (self.reverseRatio * self.finalDrive) or ((self.ratios[gear] or 0) * self.finalDrive)
    return outputRadS * r * 60.0 / (2.0 * math.pi)
end

--- Advance the gearbox.
-- @param dt seconds
-- @param engineRpm current engine rpm
-- @param throttle 0..1
-- @param outputRadS driveshaft/wheel-side angular speed (rad/s, signed with travel direction)
-- @param vehicleSpeed m/s (signed)
function Gearbox:step(dt, engineRpm, throttle, outputRadS, vehicleSpeed)
    if self.shiftTimer > 0.0 then
        self.shiftTimer = self.shiftTimer - dt
        if self.shiftTimer <= 0.0 then
            self.shiftTimer = 0.0
            self.gear = self.targetGear
            self.autoHoldTimer = 0.8   -- do not immediately shift again
        end
        return
    end

    if self:isManual() or self.lever ~= "D" then return end

    self.autoHoldTimer = math.max(0.0, self.autoHoldTimer - dt)
    if self.autoHoldTimer > 0.0 then return end

    -- Automatic logic in D.
    local upshiftRpm = wmath.lerp(self.upshiftMin, self.upshiftMax, throttle * throttle)
    local downshiftRpm = wmath.lerp(self.downshiftMin, self.downshiftMax, throttle)

    if self.gear >= 1 and self.gear < self.numGears and engineRpm > upshiftRpm and vehicleSpeed > 1.0 then
        self:requestGear(self.gear + 1)
        return
    end

    if self.gear > 1 then
        local rpmLower = self:rpmInGear(self.gear - 1, math.abs(outputRadS))
        -- Kickdown: heavy throttle and the lower gear would not over-rev.
        local kickdown = throttle > 0.85 and rpmLower < self.maxRpm * 0.95 and engineRpm < upshiftRpm * 0.8
        if engineRpm < downshiftRpm or kickdown then
            self:requestGear(self.gear - 1)
            return
        end
    end
end

WRP.Sim = WRP.Sim or {}
WRP.Sim.Gearbox = Gearbox
return Gearbox
