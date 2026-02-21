local Cond = require("Packs.PackTemplate.Conditions")
local Act = require("Packs.PackTemplate.Actions")

local Script = {}
Script.__index = Script

function Script.New(api)
    return setmetatable({ Api = api }, Script)
end

function Script:Execute(ctx, result)
    local ok, reason = Cond.CanRun(ctx)
    result:AddStep("Condition", "CanRun", ok, reason)
    if not ok then
        return false, reason
    end

    local ok2, reason2 = Act.MarkExecuted(ctx, "TemplatePulse")
    result:AddStep("Action", "MarkExecuted", ok2, reason2)
    if not ok2 then
        return false, reason2
    end
    return true, nil
end

return Script
