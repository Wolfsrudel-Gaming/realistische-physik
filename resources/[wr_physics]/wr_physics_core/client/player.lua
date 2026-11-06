--- wr_physics core (client): local player / vehicle tracking.
-- Fires local events the modules subscribe to:
--   wr_physics:client:enteredVehicle (vehicle, seat)   seat -1 = driver
--   wr_physics:client:leftVehicle (vehicle)
--   wr_physics:client:seatChanged (vehicle, seat)
--   wr_physics:client:becameDriver (vehicle) / lostDriver (vehicle)
local Player = { vehicle = 0, seat = nil, isDriver = false }

local function seatOf(ped, veh)
    for seat = -1, GetVehicleMaxNumberOfPassengers(veh) - 1 do
        if GetPedInVehicleSeat(veh, seat) == ped then return seat end
    end
    return nil
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local veh = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
        if veh ~= Player.vehicle then
            if Player.vehicle ~= 0 then
                if Player.isDriver then TriggerEvent("wr_physics:client:lostDriver", Player.vehicle) end
                TriggerEvent("wr_physics:client:leftVehicle", Player.vehicle)
            end
            Player.vehicle = veh
            Player.seat = veh ~= 0 and seatOf(ped, veh) or nil
            Player.isDriver = Player.seat == -1
            if veh ~= 0 then
                TriggerEvent("wr_physics:client:enteredVehicle", veh, Player.seat)
                if Player.isDriver then TriggerEvent("wr_physics:client:becameDriver", veh) end
            end
        elseif veh ~= 0 then
            local seat = seatOf(ped, veh)
            if seat ~= Player.seat then
                local wasDriver = Player.isDriver
                Player.seat = seat
                Player.isDriver = seat == -1
                TriggerEvent("wr_physics:client:seatChanged", veh, seat)
                if Player.isDriver and not wasDriver then TriggerEvent("wr_physics:client:becameDriver", veh) end
                if wasDriver and not Player.isDriver then TriggerEvent("wr_physics:client:lostDriver", veh) end
            end
        end
        Wait(250)
    end
end)

--- True if this client currently simulates `veh` (network owner).
function Player.ownsEntity(veh)
    return veh ~= 0 and NetworkHasControlOfEntity(veh)
end

WRP.Player = Player
