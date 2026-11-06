--- wr_physics core: locales (F72). Language via convar `wrp_locale` (default "de").
-- Each module ships locales/<lang>.json with flat keys; keys are namespaced by module name.
local Locale = {}
local strings = {}
local lang = (GetConvar and GetConvar("wrp_locale", "de")) or "de"

--- Load a module's locale file into the shared table. Call from each resource at startup.
function Locale.load(resourceName)
    local function read(l)
        local raw = LoadResourceFile(resourceName, ("locales/%s.json"):format(l))
        if not raw then return nil end
        local ok, data = pcall(json.decode, raw)
        return ok and data or nil
    end
    local data = read(lang) or read("en")
    if not data then return false end
    for k, v in pairs(data) do strings[k] = v end
    return true
end

--- Translate key with optional string.format arguments. Missing keys return the key itself.
function Locale.t(key, ...)
    local s = strings[key]
    if not s then return key end
    if select("#", ...) > 0 then
        local ok, out = pcall(string.format, s, ...)
        if ok then return out end
    end
    return s
end

function Locale.lang() return lang end

WRP.Locale = Locale
WRP.t = Locale.t
return Locale
