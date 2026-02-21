local Script = {}
Script.__index = Script

function Script.New(api)
    local o = {
        Api = api,
    }
    return setmetatable(o, Script)
end

function Script:Execute(ctx, result)
    local Condition = self.Api.Condition
    local Action = self.Api.Action
    local eventBus = self.Api.EventBus

    local ok, reason = Condition.All(ctx, {
        function()
            return Condition.AgeAtLeast(ctx, 18)
        end,
        function()
            return Condition.CheckDice(ctx, 0.75)
        end,
    })
    result:AddStep("Condition", "All", ok, reason)
    if not ok then
        eventBus:Emit("OnConditionFailed", { ScriptId = "Example_RelationshipBoost", Reason = reason })
        return false, reason
    end

    local ok1, r1 = Action.AddBuff(ctx, "Inspired", 120)
    result:AddStep("Action", "AddBuff", ok1, r1)
    if not ok1 then
        return false, r1
    end
    eventBus:Emit("BuffAdded", { BuffId = "Inspired", Duration = 120 })

    local targetId = ctx.Target and (ctx.Target.Id or "UnknownTarget") or "UnknownTarget"
    local ok2, r2 = Action.SetRelationship(ctx, targetId, 5)
    result:AddStep("Action", "SetRelationship", ok2, r2)
    if not ok2 then
        return false, r2
    end
    eventBus:Emit("RelationshipChanged", { TargetId = targetId, Delta = 5 })

    local ok3, r3 = Action.PlayFX(ctx, "FX_LevelUp")
    result:AddStep("Action", "PlayFX", ok3, r3)
    if not ok3 then
        return false, r3
    end

    return true, nil
end

return Script
