--- wr_physics core: table utilities (deep copy / deep merge).
local T = {}

function T.deepcopy(src)
    if type(src) ~= "table" then return src end
    local out = {}
    for k, v in pairs(src) do out[k] = T.deepcopy(v) end
    return setmetatable(out, getmetatable(src))
end

--- Deep-merge `over` into a copy of `base`. Arrays (sequence tables) in `over` replace, maps merge.
function T.deepmerge(base, over)
    local out = T.deepcopy(base)
    if type(over) ~= "table" then return over == nil and out or over end
    for k, v in pairs(over) do
        if type(v) == "table" and type(out[k]) == "table" and #v == 0 and #out[k] == 0 then
            out[k] = T.deepmerge(out[k], v)
        else
            out[k] = T.deepcopy(v)
        end
    end
    return out
end

--- Count entries in a map.
function T.count(t)
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

WRP = WRP or {}
WRP.Table = T
return T
