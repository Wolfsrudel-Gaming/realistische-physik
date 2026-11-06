--- wr_physics core: scalar math helpers.
-- Pure Lua, no natives. Shared between client, server and the offline test runner.
local M = {}

local abs, max, min = math.abs, math.max, math.min

--- Clamp x into [lo, hi].
function M.clamp(x, lo, hi)
    if x < lo then return lo end
    if x > hi then return hi end
    return x
end

--- Linear interpolation between a and b by t in [0, 1].
function M.lerp(a, b, t)
    return a + (b - a) * t
end

--- Inverse lerp: where x lies between a and b, as 0..1 (clamped).
function M.invLerp(a, b, x)
    if a == b then return 0.0 end
    return M.clamp((x - a) / (b - a), 0.0, 1.0)
end

--- Remap x from [inLo, inHi] to [outLo, outHi] (clamped).
function M.remap(x, inLo, inHi, outLo, outHi)
    return M.lerp(outLo, outHi, M.invLerp(inLo, inHi, x))
end

--- Sign of x: -1, 0 or 1.
function M.sign(x)
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

--- Smoothstep between edges.
function M.smoothstep(edge0, edge1, x)
    local t = M.invLerp(edge0, edge1, x)
    return t * t * (3.0 - 2.0 * t)
end

--- Apply a symmetric deadzone to an axis in [-1, 1] and rescale.
function M.deadzone(x, dz)
    if abs(x) < dz then return 0.0 end
    local s = M.sign(x)
    return s * (abs(x) - dz) / (1.0 - dz)
end

--- Move current toward target by at most maxDelta.
function M.moveToward(current, target, maxDelta)
    local d = target - current
    if abs(d) <= maxDelta then return target end
    return current + M.sign(d) * maxDelta
end

--- First-order low-pass filter step. tau = time constant in seconds.
function M.lowpass(prev, input, dt, tau)
    if tau <= 0 then return input end
    local a = dt / (tau + dt)
    return prev + (input - prev) * a
end

--- Approximate equality.
function M.approx(a, b, eps)
    return abs(a - b) <= (eps or 1e-6)
end

--- Round to n decimals.
function M.round(x, n)
    local p = 10 ^ (n or 0)
    return math.floor(x * p + 0.5) / p
end

M.max, M.min, M.abs = max, min, abs

--- Simple PI controller object.
-- @param kp proportional gain
-- @param ki integral gain
-- @param outMin/outMax output clamp
-- @param iMax integral clamp (absolute)
function M.newPI(kp, ki, outMin, outMax, iMax)
    local pi = { kp = kp, ki = ki, outMin = outMin, outMax = outMax, iMax = iMax or 1e9, i = 0.0 }
    function pi:step(err, dt)
        self.i = M.clamp(self.i + err * dt, -self.iMax, self.iMax)
        return M.clamp(self.kp * err + self.ki * self.i, self.outMin, self.outMax)
    end
    function pi:reset() self.i = 0.0 end
    return pi
end

WRP = WRP or {}
WRP.Math = M
return M
