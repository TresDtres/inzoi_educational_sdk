local QuestConditions = {}

function QuestConditions.HasQuest(ctx, questId)
    local meta = ctx.Meta or {}
    local quests = meta.Quests or {}
    if quests[questId] ~= nil then
        return true, nil
    end
    return false, "QuestNotFound"
end

function QuestConditions.IsQuestState(ctx, questId, expectedState)
    local meta = ctx.Meta or {}
    local quests = meta.Quests or {}
    local q = quests[questId]
    if q and q.State == expectedState then
        return true, nil
    end
    return false, "InvalidQuestState"
end

return QuestConditions
