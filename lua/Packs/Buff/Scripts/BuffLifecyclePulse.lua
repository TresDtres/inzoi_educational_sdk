local Cond = require("Packs.Buff.Conditions")
local Act = require("Packs.Buff.Actions")

local Script = {}
Script.__index = Script

function Script.New(api)
    return setmetatable({ Api = api }, Script)
end

function Script:Execute(ctx, result)
    local buffId = "Focused"
    local ok1, r1 = Cond.CanAddBuff(ctx, buffId)
    result:AddStep("Condition", "CanAddBuff", ok1, r1)

    if ok1 then
        local okA, rA = Act.AddTimedBuff(ctx, buffId, 90)
        result:AddStep("Action", "AddTimedBuff", okA, rA)
        if not okA then
            return false, rA
        end
        self.Api.EventBus:Emit("BuffAdded", { BuffId = buffId, Duration = 90 })
        return true, nil
    end

    local okR, rR = Act.RemoveBuff(ctx, buffId)
    result:AddStep("Action", "RemoveBuff", okR, rR)
    if not okR then
        return false, rR
    end
    self.Api.EventBus:Emit("BuffRemoved", { BuffId = buffId })
    return true, nil
end

return Script
