--- wr_physics vehicle: datasheet registry (lookup by id, model name, class fallback).
local Spec = WRP.Spec
local Classes = WRP.SpecClasses
local Data = WRP.VehicleData

local Registry = {}
local resolvedCache = {}

--- Resolve (and cache) the datasheet with the given id. Returns nil if unknown.
function Registry.byId(id)
    if resolvedCache[id] then return resolvedCache[id] end
    local raw = Data.sheets[id]
    if not raw then return nil end
    local ok, spec = pcall(Spec.resolve, raw)
    if not ok then
        error(("Registry: datasheet '%s' failed to resolve: %s"):format(id, tostring(spec)))
    end
    resolvedCache[id] = spec
    return spec
end

--- Lookup by GTA model name (lowercase). Returns spec, isFallback.
-- @param modelName string
-- @param classId GTA vehicle class id for the fallback
function Registry.forModel(modelName, classId)
    local id = Data.vanillaMap[modelName] or Data.sheets[modelName] and modelName
    if id then
        local spec = Registry.byId(id)
        if spec then return spec, false end
    end
    local key = "class:" .. tostring(classId)
    if not resolvedCache[key] then
        local raw = Classes.forClass(classId)
        local copy = {}
        for k, v in pairs(raw) do copy[k] = v end
        copy.id = key
        copy.name = raw.name or ("Class " .. tostring(classId))
        resolvedCache[key] = Spec.resolve(copy)
    end
    return resolvedCache[key], true
end

function Registry.ids()
    local out = {}
    for id in pairs(Data.sheets) do out[#out + 1] = id end
    table.sort(out)
    return out
end

WRP.SpecRegistry = Registry
return Registry
