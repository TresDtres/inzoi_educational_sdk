local I18n = {}
I18n.__index = I18n

local function interpolate(template, params)
    if type(template) ~= "string" then
        return tostring(template)
    end
    params = params or {}
    return (template:gsub("{([%w_]+)}", function(key)
        local v = params[key]
        if v == nil then
            return "{" .. key .. "}"
        end
        return tostring(v)
    end))
end

function I18n.New(opts)
    opts = opts or {}
    local o = {
        Locale = opts.locale or "en",
        FallbackLocale = opts.fallback_locale or "en",
        _bundles = {},
    }
    return setmetatable(o, I18n)
end

function I18n:RegisterLocale(localeCode, dict)
    self._bundles[localeCode] = dict or {}
end

function I18n:SetLocale(localeCode)
    if self._bundles[localeCode] then
        self.Locale = localeCode
        return true
    end
    return false
end

function I18n:T(key, params)
    local current = self._bundles[self.Locale] or {}
    local fallback = self._bundles[self.FallbackLocale] or {}
    local raw = current[key]
    if raw == nil then
        raw = fallback[key]
    end
    if raw == nil then
        return "[" .. tostring(key) .. "]"
    end
    return interpolate(raw, params)
end

return I18n
