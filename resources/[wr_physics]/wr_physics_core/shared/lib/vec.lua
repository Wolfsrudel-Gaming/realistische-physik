--- wr_physics core: plain-table 3D vectors.
-- FiveM has a native vector3 type; this module exists so the simulation layer can run
-- outside the game (tests, offline simulator). Conversion helpers at the bottom.
local V = {}
V.__index = V

local sqrt = math.sqrt

function V.new(x, y, z)
    return setmetatable({ x = x or 0.0, y = y or 0.0, z = z or 0.0 }, V)
end

function V.zero() return V.new(0.0, 0.0, 0.0) end

function V.__add(a, b) return V.new(a.x + b.x, a.y + b.y, a.z + b.z) end
function V.__sub(a, b) return V.new(a.x - b.x, a.y - b.y, a.z - b.z) end
function V.__unm(a) return V.new(-a.x, -a.y, -a.z) end
function V.__mul(a, b)
    if type(a) == "number" then return V.new(a * b.x, a * b.y, a * b.z) end
    if type(b) == "number" then return V.new(a.x * b, a.y * b, a.z * b) end
    return V.new(a.x * b.x, a.y * b.y, a.z * b.z)
end
function V.__div(a, s) return V.new(a.x / s, a.y / s, a.z / s) end
function V.__eq(a, b) return a.x == b.x and a.y == b.y and a.z == b.z end
function V.__tostring(a) return string.format("vec(%.3f, %.3f, %.3f)", a.x, a.y, a.z) end

function V.dot(a, b) return a.x * b.x + a.y * b.y + a.z * b.z end
function V.cross(a, b)
    return V.new(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x)
end
function V.len(a) return sqrt(a.x * a.x + a.y * a.y + a.z * a.z) end
function V.len2(a) return a.x * a.x + a.y * a.y + a.z * a.z end
function V.dist(a, b) return V.len(a - b) end
function V.normalized(a)
    local l = V.len(a)
    if l < 1e-12 then return V.zero() end
    return a / l
end
function V.lerp(a, b, t) return a + (b - a) * t end
--- Component of a along unit vector n.
function V.along(a, n) return V.dot(a, n) end
--- Project a onto plane with normal n (n must be unit length).
function V.projectOnPlane(a, n) return a - n * V.dot(a, n) end

V.len = V.len; V.length = V.len

--- Convert from a FiveM vector3 (or any table with x,y,z).
function V.from(v) return V.new(v.x, v.y, v.z) end

WRP = WRP or {}
WRP.Vec = V
return V
