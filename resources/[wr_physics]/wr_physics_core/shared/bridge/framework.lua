--- wr_physics core: framework bridge (F71). Detects ESX Legacy, QBCore, Qbox or runs standalone.
-- Only the small surface the physics modules need is exposed here; everything else stays in
-- the frameworks. Server-side functions take a server id; client-side functions have none.
local Bridge = { name = "standalone" }

local function started(res) return GetResourceState(res) == "started" end

if started("es_extended") then
    Bridge.name = "esx"
elseif started("qbx_core") then
    Bridge.name = "qbox"
elseif started("qb-core") then
    Bridge.name = "qbcore"
end

local isServer = IsDuplicityVersion()

if isServer then
    --- Stable identifier for a player (license), independent of the framework.
    function Bridge.identifier(src)
        for i = 0, GetNumPlayerIdentifiers(src) - 1 do
            local id = GetPlayerIdentifier(src, i)
            if id:sub(1, 8) == "license:" then return id end
        end
        return nil
    end

    --- Admin check used by the devtools and the live-tuning editor.
    function Bridge.isAdmin(src)
        if IsPlayerAceAllowed(src, "wr_physics.admin") then return true end
        if Bridge.name == "esx" then
            local ESX = exports["es_extended"]:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer then
                local g = xPlayer.getGroup()
                return g == "admin" or g == "superadmin" or g == "_dev"
            end
        elseif Bridge.name == "qbcore" then
            local QBCore = exports["qb-core"]:GetCoreObject()
            return QBCore.Functions.HasPermission(src, "admin") or QBCore.Functions.HasPermission(src, "god")
        elseif Bridge.name == "qbox" then
            return exports.qbx_core:HasPermission(src, "admin")
        end
        return false
    end
else
    --- True once the framework reports the player as loaded (or immediately for standalone).
    function Bridge.isPlayerLoaded()
        if Bridge.name == "esx" then
            local ESX = exports["es_extended"]:getSharedObject()
            return ESX.IsPlayerLoaded()
        elseif Bridge.name == "qbcore" then
            return LocalPlayer.state.isLoggedIn == true
        elseif Bridge.name == "qbox" then
            return LocalPlayer.state.isLoggedIn == true
        end
        return true
    end
end

WRP.Bridge = Bridge
return Bridge
