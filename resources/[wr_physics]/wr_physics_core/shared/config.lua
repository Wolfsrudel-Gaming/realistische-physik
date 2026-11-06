--- wr_physics core: configuration.
-- Defaults live here. Servers override via convars in server.cfg (`setr wrp_<path> <value>`,
-- replicated to clients) without touching the resource. Example:
--   setr wrp_world_scale 8.5
--   setr wrp_vehicle_coupling hybrid
--   setr wrp_modules_vehicle 1
local Table = WRP.Table

local Config = {
    -- Which modules are allowed to run (F114). A module resource that is started while its flag
    -- is 0 logs a notice and stays idle.
    modules = {
        vehicle = true,
        devtools = true,
    },

    world = {
        -- World scale factor k (F127). 1.0 until spike S9 has measured it; distance-dependent
        -- quantities (fuel, wear, odometer) are multiplied by k while moving.
        scale = 1.0,
        -- Air density at sea level [kg/m^3]; the weather module will drive this later.
        airDensity = 1.225,
    },

    performance = {
        -- Target frame budget for all wr_physics client work [ms]. The scheduler degrades
        -- lower-priority jobs when the budget is exceeded.
        frameBudgetMs = 1.5,
        -- Simulation substeps per frame for stiff subsystems (clutch/engine).
        substeps = 2,
        -- State bag replication rate for vehicle telemetry [Hz].
        stateBagHz = 6,
    },

    vehicle = {
        -- Coupling strategy between the simulation and the game's drive physics (spike S1/S2):
        --   power  : scale the game's engine torque per frame (SetVehicleCheatPowerIncrease)
        --   force  : apply the simulated tractive force directly (ApplyForceToEntity)
        --   hybrid : power scaling with a PI controller on acceleration, force for the residual
        coupling = "hybrid",
        -- Clamp of the per-frame torque multiplier used by the power/hybrid strategies.
        powerMultMax = 6.0,
        -- Residual force clamp as a fraction of mass*g (hybrid/force).
        residualForceMaxG = 0.35,
        -- Keyboard steering ramp is left to the game for now (F122). Clutch input modes:
        --   button | axis
        clutchMode = "button",
        -- Seconds for a clutch button press to reach fully pressed / fully released.
        clutchButtonRate = 0.25,
        -- Start the engine automatically when entering (false = realistic: driver must start it).
        autoStartOnEnter = false,
        -- Allow unknown models to run on class fallback datasheets (F132).
        allowClassFallback = true,
        -- Mirror the simulated tank level into the game's fuel level (so the game's own
        -- "out of fuel" behaviour and third-party HUDs stay consistent). Disable when another
        -- fuel script owns the game fuel level.
        syncGameFuel = true,
    },

    devtools = {
        telemetryDefaultOn = false,
    },
}

--- Read overrides from replicated convars. Nested keys are joined with '_':
-- Config.vehicle.coupling -> convar wrp_vehicle_coupling
local function applyConvars(tbl, prefix)
    for k, v in pairs(tbl) do
        local name = prefix .. "_" .. k
        if type(v) == "table" then
            applyConvars(v, name)
        else
            local raw = GetConvar(name, "\0")
            if raw ~= "\0" then
                if type(v) == "boolean" then
                    tbl[k] = (raw == "1" or raw == "true")
                elseif type(v) == "number" then
                    tbl[k] = tonumber(raw) or v
                else
                    tbl[k] = raw
                end
            end
        end
    end
end

if GetConvar then
    applyConvars(Config, "wrp")
end

--- Return a deep copy so modules cannot mutate shared config by accident.
function Config.snapshot() return Table.deepcopy(Config) end

WRP.Config = Config
return Config
