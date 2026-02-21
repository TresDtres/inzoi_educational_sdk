local Result = {}
Result.__index = Result

function Result.New(scriptId)
    local o = {
        ScriptId = scriptId or "unknown",
        Success = false,
        Error = nil,
        Steps = {},
    }
    return setmetatable(o, Result)
end

function Result:AddStep(stage, name, ok, reason)
    table.insert(self.Steps, {
        Stage = stage,
        Name = name,
        Ok = ok,
        Reason = reason,
    })
end

return Result
