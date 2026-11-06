-- luacheck configuration for wr_physics (Lua 5.4 / CfxLua)
std = "lua54"
max_line_length = 220
ignore = { "581" }
codes = true
self = false

-- Shared namespace and test framework globals
globals = { "WRP" }
read_globals = {
    -- test runner
    "describe", "it", "expect",
    -- FiveM runtime
    "json", "vector3", "vector2", "vector4", "quat", "Citizen", "CreateThread", "Wait", "SetTimeout",
    "GetGameTimer", "GetFrameTime", "GetCurrentResourceName", "GetResourceMetadata", "GetResourceState",
    "GetConvar", "GetConvarInt", "LoadResourceFile", "SaveResourceFile", "IsDuplicityVersion",
    "RegisterCommand", "RegisterKeyMapping", "RegisterNetEvent", "AddEventHandler", "TriggerEvent",
    "TriggerServerEvent", "TriggerClientEvent", "exports", "source", "Entity", "LocalPlayer",
    "AddStateBagChangeHandler", "SetHttpHandler", "MySQL", "GetPlayers", "GetPlayerName", "GetPlayerPed",
    "GetPlayerIdentifier", "GetNumPlayerIdentifiers", "IsPlayerAceAllowed", "GetHashKey", "GetGameBuildNumber",
    "SendNUIMessage", "RegisterNUICallback", "SetNuiFocus",
    -- natives used (client)
    "PlayerPedId", "PlayerId", "IsPedInAnyVehicle", "GetVehiclePedIsIn", "GetPedInVehicleSeat",
    "GetVehicleMaxNumberOfPassengers", "DoesEntityExist", "GetEntityModel", "GetDisplayNameFromVehicleModel",
    "GetVehicleClass", "GetEntitySpeed", "GetEntitySpeedVector", "GetEntityCoords", "GetVehicleNumberOfWheels",
    "GetVehicleWheelSpeed", "GetVehicleWheelSurfaceMaterial", "GetVehicleWheelSuspensionCompression",
    "GetVehicleHandlingFloat", "GetVehicleHandlingInt", "SetVehicleHandlingFloat", "SetVehicleCheatPowerIncrease",
    "ApplyForceToEntity", "SetVehicleCurrentRpm", "GetVehicleCurrentRpm", "SetVehicleCurrentGear",
    "SetVehicleNextGear", "GetVehicleCurrentGear", "GetVehicleHighGear", "SetVehicleClutch", "GetVehicleClutch",
    "SetVehicleEngineOn", "GetIsVehicleEngineRunning", "SetVehicleFuelLevel", "GetVehicleFuelLevel",
    "GetVehicleNumberPlateText", "NetworkGetNetworkIdFromEntity", "NetworkGetEntityFromNetworkId",
    "NetworkHasControlOfEntity", "NetworkGetEntityOwner", "DisableControlAction", "GetControlNormal",
    "GetDisabledControlNormal", "IsControlPressed", "BeginTextCommandThefeedPost",
    "AddTextComponentSubstringPlayerName", "EndTextCommandThefeedPostTicker", "SetTextFont", "SetTextScale",
    "SetTextColour", "SetTextOutline", "SetTextEntry", "AddTextComponentString", "DrawText",
}

files["tests/run.lua"] = { globals = { "describe", "it", "expect" } }
files["tools/sim/accel.lua"] = { ignore = { "121" } }

exclude_files = { "web/node_modules", "companion", "**/fxmanifest.lua" }
