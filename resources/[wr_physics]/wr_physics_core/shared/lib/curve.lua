--- wr_physics core: 1D lookup curves and 2D maps with linear interpolation.
-- Used for torque curves, BSFC maps, tyre tables, lift/drag polars etc.
local Curve = {}
Curve.__index = Curve

--- Create a 1D curve from points {{x, y}, ...}. Points are sorted by x.
function Curve.new(points)
    assert(type(points) == "table" and #points >= 1, "Curve.new: need at least one point")
    local pts = {}
    for i, p in ipairs(points) do
        pts[i] = { p[1], p[2] }
    end
    table.sort(pts, function(a, b) return a[1] < b[1] end)
    return setmetatable({ pts = pts }, Curve)
end

--- Evaluate at x. Clamps to the first/last point outside the range.
function Curve:at(x)
    local pts = self.pts
    local n = #pts
    if x <= pts[1][1] then return pts[1][2] end
    if x >= pts[n][1] then return pts[n][2] end
    -- binary search for segment
    local lo, hi = 1, n
    while hi - lo > 1 do
        local mid = (lo + hi) // 2
        if pts[mid][1] <= x then lo = mid else hi = mid end
    end
    local a, b = pts[lo], pts[hi]
    local t = (x - a[1]) / (b[1] - a[1])
    return a[2] + (b[2] - a[2]) * t
end

--- Domain of the curve.
function Curve:domain()
    return self.pts[1][1], self.pts[#self.pts][1]
end

--- Maximum y value and the x where it occurs (checks sample points only).
function Curve:max()
    local bx, by = self.pts[1][1], self.pts[1][2]
    for _, p in ipairs(self.pts) do
        if p[2] > by then bx, by = p[1], p[2] end
    end
    return by, bx
end

--- Return a new curve with all y scaled by factor.
function Curve:scaled(factor)
    local pts = {}
    for i, p in ipairs(self.pts) do pts[i] = { p[1], p[2] * factor } end
    return Curve.new(pts)
end

--- 2D map: rows indexed by y, columns by x. data = { xs = {...}, ys = {...}, z = {{...}, ...} }
-- z[iy][ix]. Bilinear interpolation, clamped at the borders.
local Map2 = {}
Map2.__index = Map2
Curve.Map2 = Map2

function Map2.new(xs, ys, z)
    assert(#z == #ys, "Map2.new: z rows must match ys")
    for iy = 1, #ys do assert(#z[iy] == #xs, "Map2.new: z cols must match xs") end
    return setmetatable({ xs = xs, ys = ys, z = z }, Map2)
end

local function locate(arr, v)
    local n = #arr
    if v <= arr[1] then return 1, 1, 0.0 end
    if v >= arr[n] then return n, n, 0.0 end
    local lo, hi = 1, n
    while hi - lo > 1 do
        local mid = (lo + hi) // 2
        if arr[mid] <= v then lo = mid else hi = mid end
    end
    return lo, hi, (v - arr[lo]) / (arr[hi] - arr[lo])
end

function Map2:at(x, y)
    local x0, x1, tx = locate(self.xs, x)
    local y0, y1, ty = locate(self.ys, y)
    local z = self.z
    local a = z[y0][x0] + (z[y0][x1] - z[y0][x0]) * tx
    local b = z[y1][x0] + (z[y1][x1] - z[y1][x0]) * tx
    return a + (b - a) * ty
end

WRP = WRP or {}
WRP.Curve = Curve
return Curve
