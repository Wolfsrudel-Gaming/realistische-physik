--- wr_physics devtools (client): spike commands (phase 0).
--   /wrp_material   toggle per-wheel surface material readout (S8)
--   /wrp_net        print network ownership + state bag of the current vehicle (S3)
--   /wrp_scale      print GTA distances of the world-scale reference pairs (S9)
--   /wrp_handling   print the key handling values of the current vehicle
local Units = WRP.Units
local log = WRP.Log.tag("spike")

-- S8: material readout ---------------------------------------------------------------------
local materialOn = false
local materialNames = {}  -- hash -> name, filled lazily from a small known list
local KNOWN = {
    "concrete", "concrete_pothole", "concrete_dusty", "tarmac", "tarmac_painted", "tarmac_pothole", "rumble_strip",
    "breeze_block", "rock", "rock_mossy", "stone", "cobblestone", "brick", "marble", "paving_slab", "sandstone_solid",
    "sandstone_brittle", "sand_loose", "sand_compact", "sand_wet", "sand_track", "sand_underwater", "sand_dry_deep",
    "sand_wet_deep", "ice", "ice_tarmac", "snow_loose", "snow_compact", "snow_deep", "snow_tarmac", "gravel_small",
    "gravel_large", "gravel_deep", "gravel_train_track", "dirt_track", "mud_hard", "mud_pothole", "mud_soft",
    "mud_underwater", "mud_deep", "marsh", "marsh_deep", "soil", "clay_hard", "clay_soft", "grass_long", "grass",
    "grass_short", "hay", "bushes", "twigs", "leaves", "woodchips", "tree_bark", "metal_solid_small", "metal_solid_medium",
    "metal_solid_large", "metal_hollow_small", "metal_hollow_medium", "metal_hollow_large", "metal_chainlink_small",
    "metal_chainlink_large", "metal_corrugated_iron", "metal_grille", "metal_railing", "metal_duct", "metal_garage_door",
    "metal_manhole", "wood_solid_small", "wood_solid_medium", "wood_solid_large", "wood_solid_polished",
    "wood_floor_dusty", "wood_hollow_small", "wood_hollow_medium", "wood_hollow_large", "wood_chipboard",
    "wood_old_creaky", "wood_high_density", "wood_lattice", "plastic", "plastic_hollow", "rubber", "rubber_hollow",
    "carpet_solid", "glass_shoot_through", "glass_bulletproof", "water", "default",
}
for _, n in ipairs(KNOWN) do materialNames[GetHashKey(n)] = n end

local function drawText(x, y, text)
    SetTextFont(4); SetTextScale(0.32, 0.32); SetTextColour(255, 255, 255, 220); SetTextOutline()
    SetTextEntry("STRING"); AddTextComponentString(text); DrawText(x, y)
end

CreateThread(function()
    while true do
        if materialOn then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                local n = GetVehicleNumberOfWheels(veh)
                for i = 0, n - 1 do
                    local mat = GetVehicleWheelSurfaceMaterial(veh, i)
                    local name = materialNames[mat] or ("0x" .. string.format("%X", mat & 0xFFFFFFFF))
                    local speed = GetVehicleWheelSpeed(veh, i)
                    local comp = GetVehicleWheelSuspensionCompression(veh, i)
                    drawText(0.015, 0.55 + i * 0.022, ("W%d %-22s v=%5.1f m/s  susp=%.3f"):format(i, name, speed, comp))
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

RegisterCommand("wrp_material", function()
    materialOn = not materialOn
    log.info("material readout %s", materialOn and "on" or "off")
end, false)

-- S3: network info -----------------------------------------------------------------------
RegisterCommand("wrp_net", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then log.info("not in a vehicle") return end
    local netId = NetworkGetNetworkIdFromEntity(veh)
    local owner = NetworkGetEntityOwner(veh)
    local st = Entity(veh).state["wrp:veh"]
    log.info("netId=%d owner=%d (me=%d) hasControl=%s engineOn=%s", netId, owner, PlayerId(),
        tostring(NetworkHasControlOfEntity(veh)), tostring(Entity(veh).state["wrp:engineOn"]))
    if st then
        log.info("state wrp:veh: rpm=%s gear=%s on=%s fuel=%s spec=%s", tostring(st.rpm), tostring(st.gear), tostring(st.on), tostring(st.fuel), tostring(st.spec))
    else
        log.info("state wrp:veh: (none)")
    end
end, false)

-- S9: world scale reference pairs --------------------------------------------------------
-- GTA coordinates of landmarks and the real-world distance of the places they are modelled on.
-- realKm values are approximate road distances between the real-world counterparts and must be
-- reviewed in the spike report (docs/spikes/S9-world-scale.md).
local REF = {
    { "LSIA (LAX) -> Paleto Bay (Fort Bragg/Crescent City analogue)", vector3(-1037.0, -2737.0, 20.0), vector3(-275.0, 6228.0, 31.0), realKm = 900 },
    { "Downtown LS (DTLA) -> Sandy Shores (Salton Sea)", vector3(-230.0, -850.0, 30.0), vector3(1960.0, 3740.0, 32.0), realKm = 260 },
    { "Del Perro Pier (Santa Monica) -> Downtown LS (DTLA)", vector3(-1850.0, -1230.0, 13.0), vector3(-230.0, -850.0, 30.0), realKm = 25 },
    { "Vespucci Beach (Venice) -> LSIA (LAX)", vector3(-1420.0, -1500.0, 4.0), vector3(-1037.0, -2737.0, 20.0), realKm = 10 },
    { "Downtown LS -> Mount Chiliad summit (Mount San Antonio analogue)", vector3(-230.0, -850.0, 30.0), vector3(501.0, 5604.0, 797.0), realKm = 90 },
}

RegisterCommand("wrp_scale", function()
    log.info("World scale reference pairs (GTA straight-line distance vs. real-world approx.):")
    local sum, n = 0.0, 0
    for _, r in ipairs(REF) do
        local d = #(r[2] - r[3]) / 1000.0
        local k = r.realKm / d
        sum = sum + k; n = n + 1
        log.info("  %-62s GTA %6.2f km  real ~%4d km  k=%5.1f", r[1], d, r.realKm, k)
    end
    log.info("  mean k = %.1f  (set with: setr wrp_world_scale <k>)", sum / n)
end, false)

-- Handling readout ----------------------------------------------------------------------
RegisterCommand("wrp_handling", function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then log.info("not in a vehicle") return end
    local function h(name) return GetVehicleHandlingFloat(veh, "CHandlingData", name) end
    log.info("%s: fMass=%.0f fInitialDriveForce=%.3f fInitialDriveMaxFlatVel=%.0f fDriveInertia=%.2f fClutchChangeRateScaleUpShift=%.2f fBrakeForce=%.2f fTractionCurveMax=%.2f fTractionCurveMin=%.2f gears=%d",
        GetDisplayNameFromVehicleModel(GetEntityModel(veh)), h("fMass"), h("fInitialDriveForce"), h("fInitialDriveMaxFlatVel"),
        h("fDriveInertia"), h("fClutchChangeRateScaleUpShift"), h("fBrakeForce"), h("fTractionCurveMax"), h("fTractionCurveMin"),
        GetVehicleHandlingInt(veh, "CHandlingData", "nInitialDriveGears"))
    log.info("game: rpm=%.2f gear=%d highGear=%d clutch=%.2f speed=%.1f km/h engineOn=%s",
        GetVehicleCurrentRpm(veh), GetVehicleCurrentGear(veh), GetVehicleHighGear(veh), GetVehicleClutch(veh),
        Units.msToKmh(GetEntitySpeed(veh)), tostring(GetIsVehicleEngineRunning(veh)))
end, false)
