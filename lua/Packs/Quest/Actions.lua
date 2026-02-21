local QuestActions = {}

function QuestActions.AcceptQuest(ctx, questId)
    if type(questId) ~= "string" or questId == "" then
        return false, "QuestIdRequired"
    end
    ctx.Meta.Quests = ctx.Meta.Quests or {}
    ctx.Meta.Quests[questId] = ctx.Meta.Quests[questId] or { State = "Accepted", Progress = 0 }
    ctx.Meta.Quests[questId].State = "Accepted"
    return true, nil
end

function QuestActions.AdvanceQuest(ctx, questId, amount)
    if type(questId) ~= "string" or questId == "" then
        return false, "QuestIdRequired"
    end
    if amount ~= nil and type(amount) ~= "number" then
        return false, "AmountMustBeNumber"
    end
    if amount ~= nil and amount < 0 then
        return false, "AmountMustBePositive"
    end
    ctx.Meta.Quests = ctx.Meta.Quests or {}
    local q = ctx.Meta.Quests[questId]
    if not q then
        return false, "QuestNotFound"
    end
    q.Progress = (q.Progress or 0) + (amount or 1)
    if q.Progress >= 100 then
        q.State = "Completed"
    end
    return true, nil
end

return QuestActions
