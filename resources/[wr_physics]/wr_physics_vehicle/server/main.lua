--- wr_physics vehicle (server): vehicle identity + persisted state (fuel, odometer, engine hours).
local log = WRP.Log.tag("vehicle")
local Config = WRP.Config
local Registry = WRP.SpecRegistry

WRP.Locale.load(GetCurrentResourceName())

if not Config.modules.vehicle then
    log.warn("module disabled by configuration (wrp_modules_vehicle 0)")
    return
end

local core = exports.wr_physics_core
local pending = {}   -- netId -> vin cache

--- Resolve the entity for a net id and check the requesting player is its driver.
local function driverOf(src, netId)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 or not DoesEntityExist(veh) then return nil end
    local ped = GetPlayerPed(src)
    if GetPedInVehicleSeat(veh, -1) ~= ped then return nil end
    return veh
end

RegisterNetEvent("wr_physics:server:requestVehicleState", function(netId, plate, model)
    local src = source
    local veh = driverOf(src, netId)
    if not veh then return end
    plate = type(plate) == "string" and plate:sub(1, 12) or nil
    model = type(model) == "string" and model:sub(1, 64) or "unknown"
    local vin, st = core:loadVehicle(plate, model)
    if vin then pending[netId] = vin end
    TriggerClientEvent("wr_physics:client:vehicleState", src, netId, {
        vin = vin,
        fuelL = st and st.fuel_l or nil,
        odometerM = st and st.odometer_m or nil,
        engineHours = st and st.engine_hours or nil,
    })
end)

RegisterNetEvent("wr_physics:server:saveVehicleState", function(netId, data)
    local src = source
    if type(data) ~= "table" then return end
    local vin = data.vin or pending[netId]
    if not vin then return end
    -- Plausibility (F97): fuel within tank, odometer monotonic-ish, reasonable magnitudes.
    local fuel = tonumber(data.fuelL)
    local odo = tonumber(data.odometerM)
    local hours = tonumber(data.engineHours)
    if not fuel or not odo or not hours or fuel < 0 or fuel > 2000 or odo < 0 or odo > 5e9 or hours < 0 then
        log.warn("rejected implausible state from %s", GetPlayerName(src))
        return
    end
    core:saveVehicleState(vin, odo, fuel, hours, {})
end)

RegisterCommand("wrp_specs", function(src)
    local ids = Registry.ids()
    local msg = ("%d datasheets: %s"):format(#ids, table.concat(ids, ", "))
    if src == 0 then print(msg) else TriggerClientEvent("chat:addMessage", src, { args = { "wr_physics", msg } }) end
end, true)

log.info("vehicle module ready, %d datasheets", #Registry.ids())
