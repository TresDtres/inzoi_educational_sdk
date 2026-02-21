local Logger = {}
Logger.__index = Logger

function Logger.New(prefix, i18n)
    local o = {
        Prefix = prefix or "[EduSDK]",
        I18n = i18n,
    }
    return setmetatable(o, Logger)
end

function Logger:Info(msg)
    print(string.format("%s [INFO] %s", self.Prefix, msg))
end

function Logger:Warn(msg)
    print(string.format("%s [WARN] %s", self.Prefix, msg))
end

function Logger:Error(msg)
    print(string.format("%s [ERROR] %s", self.Prefix, msg))
end

function Logger:InfoT(key, params)
    if self.I18n then
        self:Info(self.I18n:T(key, params))
        return
    end
    self:Info("[" .. tostring(key) .. "]")
end

function Logger:WarnT(key, params)
    if self.I18n then
        self:Warn(self.I18n:T(key, params))
        return
    end
    self:Warn("[" .. tostring(key) .. "]")
end

return Logger
