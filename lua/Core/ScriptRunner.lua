local Result = require("Core.Result")

local ScriptRunner = {}
ScriptRunner.__index = ScriptRunner

function ScriptRunner.New(deps)
    deps = deps or {}
    local o = {
        EventBus = deps.EventBus,
        Logger = deps.Logger,
    }
    return setmetatable(o, ScriptRunner)
end

function ScriptRunner:Run(scriptId, scriptObj, ctx)
    local result = Result.New(scriptId)

    if self.EventBus then
        self.EventBus:Emit("OnScriptStarted", { ScriptId = scriptId })
    end

    if not scriptObj or type(scriptObj.Execute) ~= "function" then
        result.Error = "InvalidScript"
        if self.Logger then
            self.Logger:Error("Script invalido: " .. tostring(scriptId))
        end
        if self.EventBus then
            self.EventBus:Emit("OnScriptFinished", { ScriptId = scriptId, Success = false, Error = result.Error })
        end
        return result
    end

    local ok, err = scriptObj:Execute(ctx, result)
    result.Success = ok == true
    result.Error = err

    if self.EventBus then
        self.EventBus:Emit("OnScriptFinished", {
            ScriptId = scriptId,
            Success = result.Success,
            Error = result.Error,
        })
    end

    return result
end

return ScriptRunner
