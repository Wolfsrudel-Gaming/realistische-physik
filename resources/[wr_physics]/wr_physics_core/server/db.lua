--- wr_physics core (server): persistence layer (oxmysql) with migrations.
-- Tables use the prefix wr_. If oxmysql is missing the server keeps running without persistence.
local log = WRP.Log.tag("db")

local DB = { ready = false }

local migrations = {
    -- 1: schema version table + vehicle identity and state (phase 1 subset)
    [[CREATE TABLE IF NOT EXISTS wr_schema (
        version INT NOT NULL PRIMARY KEY,
        applied_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )]],
    [[CREATE TABLE IF NOT EXISTS wr_vehicles (
        vin CHAR(17) NOT NULL PRIMARY KEY,
        plate VARCHAR(12) NULL,
        model VARCHAR(64) NOT NULL,
        spec_id VARCHAR(64) NULL,
        owner VARCHAR(80) NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_plate (plate)
    )]],
    [[CREATE TABLE IF NOT EXISTS wr_vehicle_state (
        vin CHAR(17) NOT NULL PRIMARY KEY,
        odometer_m DOUBLE NOT NULL DEFAULT 0,
        fuel_l DOUBLE NULL,
        engine_hours DOUBLE NOT NULL DEFAULT 0,
        state JSON NULL,
        last_used DATETIME NULL,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    )]],
    [[CREATE TABLE IF NOT EXISTS wr_vehicle_specs (
        id VARCHAR(64) NOT NULL,
        version INT NOT NULL DEFAULT 1,
        status ENUM('draft','reviewed','approved') NOT NULL DEFAULT 'draft',
        data JSON NOT NULL,
        source VARCHAR(255) NULL,
        updated_by VARCHAR(80) NULL,
        updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id, version)
    )]],
}

local function hasMySQL()
    return GetResourceState("oxmysql") == "started" and MySQL ~= nil
end

local function migrate()
    MySQL.query.await(migrations[1])
    local rows = MySQL.query.await("SELECT version FROM wr_schema")
    local applied = {}
    for _, r in ipairs(rows or {}) do applied[r.version] = true end
    local n = 0
    for v = 2, #migrations do
        if not applied[v] then
            MySQL.query.await(migrations[v])
            MySQL.insert.await("INSERT INTO wr_schema (version) VALUES (?)", { v })
            n = n + 1
        end
    end
    return n
end

CreateThread(function()
    Wait(500)
    if not hasMySQL() then
        log.warn(WRP.t("core.db_unavailable"))
        return
    end
    local ok, n = pcall(migrate)
    if ok then
        DB.ready = true
        log.info(WRP.t("core.db_ready", n))
    else
        log.error("migration failed: %s", tostring(n))
    end
end)

--- Generate a pseudo-VIN (17 chars, no I/O/Q) for a new vehicle identity.
function DB.newVin()
    local chars = "ABCDEFGHJKLMNPRSTUVWXYZ0123456789"
    local out = {}
    for i = 1, 17 do
        local k = math.random(1, #chars)
        out[i] = chars:sub(k, k)
    end
    return table.concat(out)
end

--- Load or create the vehicle identity + state for a plate/model. Returns vin, state (or nil without DB).
function DB.loadVehicle(plate, model)
    if not DB.ready then return nil end
    plate = plate and plate:gsub("%s+$", "") or nil
    local row = plate and MySQL.single.await("SELECT vin FROM wr_vehicles WHERE plate = ? LIMIT 1", { plate })
    local vin = row and row.vin
    if not vin then
        vin = DB.newVin()
        MySQL.insert.await("INSERT INTO wr_vehicles (vin, plate, model) VALUES (?, ?, ?)", { vin, plate, model })
        MySQL.insert.await("INSERT INTO wr_vehicle_state (vin) VALUES (?)", { vin })
    end
    local st = MySQL.single.await("SELECT odometer_m, fuel_l, engine_hours, state FROM wr_vehicle_state WHERE vin = ?", { vin })
    if st and type(st.state) == "string" then st.state = json.decode(st.state) end
    return vin, st
end

function DB.saveVehicleState(vin, odometerM, fuelL, engineHours, state)
    if not DB.ready or not vin then return end
    MySQL.update("UPDATE wr_vehicle_state SET odometer_m = ?, fuel_l = ?, engine_hours = ?, state = ?, last_used = NOW() WHERE vin = ?",
        { odometerM, fuelL, engineHours, json.encode(state or {}), vin })
end

WRP.DB = DB
