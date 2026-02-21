local Cond = require("Packs.Quest.Conditions")
local Act = require("Packs.Quest.Actions")

local Script = {}
Script.__index = Script

function Script.New(api)
    return setmetatable({ Api = api }, Script)
end

function Script:Execute(ctx, result)
    local questId = "DailyQuest_01"
    local ok1, r1 = Cond.HasQuest(ctx, questId)
    result:AddStep("Condition", "HasQuest", ok1, r1)
    if not ok1 then
        local okA, rA = Act.AcceptQuest(ctx, questId)
        result:AddStep("Action", "AcceptQuest", okA, rA)
        if not okA then
            return false, rA
        end
    end

    local ok2, r2 = Act.AdvanceQuest(ctx, questId, 25)
    result:AddStep("Action", "AdvanceQuest", ok2, r2)
    if not ok2 then
        return false, r2
    end

    self.Api.EventBus:Emit("QuestUpdated", { QuestId = questId, Data = ctx.Meta.Quests[questId] })
    return true, nil
end

return Script
