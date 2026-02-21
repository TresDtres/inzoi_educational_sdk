local Cond = require("Packs.Economy.Conditions")
local Act = require("Packs.Economy.Actions")

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

    local ok2, reason2 = Act.MarkExecuted(ctx, "EconomyPulse")
    result:AddStep("Action", "MarkExecuted", ok2, reason2)
    if not ok2 then
        return false, reason2
    end

    self.Api.EventBus:Emit("EconomyChanged", { Key = "EconomyPulse" })
    return true, nil
end

return Script
