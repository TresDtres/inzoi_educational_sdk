local Registry = {}
Registry.__index = Registry

function Registry.New()
    local o = {
        _structs = {},
        _enums = {},
    }
    return setmetatable(o, Registry)
end

function Registry:RegisterStruct(name, def)
    self._structs[name] = def
end

function Registry:GetStruct(name)
    return self._structs[name]
end

function Registry:RegisterEnum(name, values)
    self._enums[name] = values
end

function Registry:ResolveEnum(name, key)
    local enum = self._enums[name]
    if not enum then
        return nil
    end
    return enum[key]
end

function Registry:ValidatePayload(structName, payload)
    local def = self._structs[structName]
    if not def then
        return false, "StructNotFound"
    end
    for fieldName, fieldType in pairs(def) do
        local value = payload[fieldName]
        if value == nil then
            return false, "MissingField:" .. fieldName
        end
        if fieldType == "number" and type(value) ~= "number" then
            return false, "InvalidType:" .. fieldName
        end
        if fieldType == "string" and type(value) ~= "string" then
            return false, "InvalidType:" .. fieldName
        end
        if fieldType == "boolean" and type(value) ~= "boolean" then
            return false, "InvalidType:" .. fieldName
        end
    end
    return true, nil
end

return Registry
