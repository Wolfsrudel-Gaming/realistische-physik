--- wr_physics vehicle (client): driver inputs.
-- Throttle/brake come from the game's own controls (so the game keeps driving). Clutch, shifting
-- and engine start are wr_physics key mappings (rebindable in Settings > Key Bindings > FiveM).
-- Axis-based clutch (gamepad/wheel via the NUI gamepad API) is phase 3d.
local wmath = WRP.Math
local Config = WRP.Config

local Input = {}
local clutchHeld = false
local clutchPedal = 0.0
local edges = { shiftUp = false, shiftDown = false, engine = false }

local CONTROL_ACCEL, CONTROL_BRAKE, CONTROL_HANDBRAKE = 71, 72, 76

RegisterCommand("+wrp_clutch", function() clutchHeld = true end, false)
RegisterCommand("-wrp_clutch", function() clutchHeld = false end, false)
RegisterCommand("wrp_shift_up", function() edges.shiftUp = true end, false)
RegisterCommand("wrp_shift_down", function() edges.shiftDown = true end, false)
RegisterCommand("wrp_engine", function() edges.engine = true end, false)

RegisterKeyMapping("+wrp_clutch", WRP.t("veh.key_clutch"), "keyboard", "LMENU")
RegisterKeyMapping("wrp_shift_up", WRP.t("veh.key_shift_up"), "keyboard", "LSHIFT")
RegisterKeyMapping("wrp_shift_down", WRP.t("veh.key_shift_down"), "keyboard", "LCONTROL")
RegisterKeyMapping("wrp_engine", WRP.t("veh.key_engine"), "keyboard", "G")

--- Sample inputs for this frame. `blockGameThrottle` disables the game's accelerate control so the
-- game does not drive the car itself (neutral, clutch pressed, reverse, engine off).
-- @return table { throttle, brake, handbrake, clutch, shiftUp, shiftDown, engineToggle }
function Input.sample(dt, blockGameThrottle)
    if blockGameThrottle then
        DisableControlAction(0, CONTROL_ACCEL, true)
    end
    local throttle = GetDisabledControlNormal(0, CONTROL_ACCEL)
    local brake = GetDisabledControlNormal(0, CONTROL_BRAKE)
    local handbrake = IsControlPressed(0, CONTROL_HANDBRAKE)

    -- Clutch as a button: ramp the pedal so a press is not instantaneous (F19 "button" mode).
    local rate = dt / math.max(Config.vehicle.clutchButtonRate, 0.01)
    clutchPedal = wmath.moveToward(clutchPedal, clutchHeld and 1.0 or 0.0, rate)

    local out = {
        throttle = throttle,
        brake = brake,
        handbrake = handbrake,
        clutch = clutchPedal,
        shiftUp = edges.shiftUp,
        shiftDown = edges.shiftDown,
        engineToggle = edges.engine,
    }
    edges.shiftUp, edges.shiftDown, edges.engine = false, false, false
    return out
end

function Input.reset()
    clutchHeld = false
    clutchPedal = 0.0
end

WRP.VehicleInput = Input
