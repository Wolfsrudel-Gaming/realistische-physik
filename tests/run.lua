--- wr_physics test runner (pure Lua 5.4, no dependencies).
-- Usage: lua5.4 tests/run.lua [filter]
-- Loads the shared libraries exactly like FiveM would (as globals under WRP) and runs every
-- tests/spec/*_spec.lua. Provides a small busted-like API: describe / it / expect.
local root = arg[0]:match("^(.*)/tests/run%.lua$") or "."
package.path = root .. "/?.lua;" .. package.path

local function load(rel)
    local chunk, err = loadfile(root .. "/" .. rel)
    if not chunk then error(err) end
    return chunk()
end

-- Load order mirrors the fxmanifest shared_scripts order.
WRP = {}
WRP.bootstrap = { load = load, root = root }
local core = "resources/[wr_physics]/wr_physics_core/shared/"
for _, f in ipairs { "lib/class.lua", "lib/wmath.lua", "lib/units.lua", "lib/curve.lua", "lib/vec.lua", "lib/deepmerge.lua" } do
    load(core .. f)
end
local veh = "resources/[wr_physics]/wr_physics_vehicle/"
for _, f in ipairs { "shared/sim/engine.lua", "shared/sim/gearbox.lua", "shared/sim/drivetrain.lua",
    "shared/sim/fuel.lua", "shared/sim/longitudinal.lua", "shared/specs/spec.lua", "shared/specs/classes.lua",
    "data/vehicles/reference.lua", "shared/specs/registry.lua" } do
    load(veh .. f)
end

-- Minimal test framework -----------------------------------------------------------------
local results = { passed = 0, failed = 0, failures = {} }
local stack = {}
local filter = arg[1]

local function fullName(name)
    local parts = {}
    for _, s in ipairs(stack) do parts[#parts + 1] = s end
    parts[#parts + 1] = name
    return table.concat(parts, " > ")
end

function describe(name, fn)
    stack[#stack + 1] = name
    fn()
    stack[#stack] = nil
end

function it(name, fn)
    local full = fullName(name)
    if filter and not full:find(filter, 1, true) then return end
    local ok, err = xpcall(fn, debug.traceback)
    if ok then
        results.passed = results.passed + 1
        io.write("  ok   ", full, "\n")
    else
        results.failed = results.failed + 1
        results.failures[#results.failures + 1] = { name = full, err = err }
        io.write("  FAIL ", full, "\n")
    end
end

local function fail(msg, level)
    error(msg, (level or 1) + 2)
end

expect = {}
function expect.eq(actual, expected, msg)
    if actual ~= expected then
        fail(("%sexpected %s, got %s"):format(msg and (msg .. ": ") or "", tostring(expected), tostring(actual)))
    end
end
function expect.near(actual, expected, tol, msg)
    tol = tol or 1e-6
    if type(actual) ~= "number" or math.abs(actual - expected) > tol then
        fail(("%sexpected %s +/- %s, got %s"):format(msg and (msg .. ": ") or "", tostring(expected), tostring(tol), tostring(actual)))
    end
end
function expect.truthy(v, msg) if not v then fail((msg or "expected truthy") .. ", got " .. tostring(v)) end end
function expect.falsy(v, msg) if v then fail((msg or "expected falsy") .. ", got " .. tostring(v)) end end
function expect.gt(a, b, msg) if not (a > b) then fail(("%sexpected %s > %s"):format(msg and (msg .. ": ") or "", tostring(a), tostring(b))) end end
function expect.lt(a, b, msg) if not (a < b) then fail(("%sexpected %s < %s"):format(msg and (msg .. ": ") or "", tostring(a), tostring(b))) end end
function expect.between(a, lo, hi, msg)
    if not (a >= lo and a <= hi) then fail(("%sexpected %s in [%s, %s]"):format(msg and (msg .. ": ") or "", tostring(a), tostring(lo), tostring(hi))) end
end
function expect.errors(fn, msg)
    local ok = pcall(fn)
    if ok then fail(msg or "expected an error") end
end

-- Discover specs -------------------------------------------------------------------------
local specDir = root .. "/tests/spec"
local p = io.popen('ls "' .. specDir .. '"')
local files = {}
for line in p:lines() do if line:match("_spec%.lua$") then files[#files + 1] = line end end
p:close()
table.sort(files)

for _, f in ipairs(files) do
    io.write(f, "\n")
    load("tests/spec/" .. f)
end

io.write(("\n%d passed, %d failed\n"):format(results.passed, results.failed))
for _, fl in ipairs(results.failures) do
    io.write("\n--- ", fl.name, "\n", fl.err, "\n")
end
os.exit(results.failed == 0 and 0 or 1)
