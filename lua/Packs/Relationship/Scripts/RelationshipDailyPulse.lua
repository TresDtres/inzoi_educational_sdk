local Cond = require("Packs.Relationship.Conditions")
local Act = require("Packs.Relationship.Actions")

local Script = {}
Script.__index = Script

function Script.New(api)
    return setmetatable({ Api = api }, Script)
end

function Script:Execute(ctx, result)
    local targetId = ctx.Target and ctx.Target.Id or nil
    local ok1, r1 = Cond.IsKnownTarget(ctx, targetId)
    result:AddStep("Condition", "IsKnownTarget", ok1, r1)
    if not ok1 then
        return false, r1
    end

    local ok2, r2 = Act.AddAffinity(ctx, targetId, 1)
    result:AddStep("Action", "AddAffinity", ok2, r2)
    if not ok2 then
        return false, r2
    end

    self.Api.EventBus:Emit("RelationshipChanged", { TargetId = targetId, Delta = 1 })
    return true, nil
end

return Script
