local T = require("Tests.TestUtils")
local Script = require("Packs.Quest.Scripts.QuestProgressPulse")
local Actions = require("Packs.Quest.Actions")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "QuestProgressPulse", script, ctx)
    T.AssertTrue("quest first success", r.Success)
    T.AssertTrue("quest exists", ctx.Meta.Quests["DailyQuest_01"] ~= nil)
    T.AssertEqual("quest progress", ctx.Meta.Quests["DailyQuest_01"].Progress, 25)

    local r2 = T.RunScript(api, "QuestProgressPulse", script, ctx)
    T.AssertTrue("quest second success", r2.Success)
    T.AssertEqual("quest progress second", ctx.Meta.Quests["DailyQuest_01"].Progress, 50)

    local ok1, err1 = Actions.AcceptQuest(ctx, nil)
    T.AssertTrue("quest id required", ok1 == false and err1 == "QuestIdRequired")

    local ok2, err2 = Actions.AdvanceQuest(ctx, "DailyQuest_01", "bad")
    T.AssertTrue("quest amount type invalid", ok2 == false and err2 == "AmountMustBeNumber")

    local ok3, err3 = Actions.AdvanceQuest(ctx, "DailyQuest_01", -5)
    T.AssertTrue("quest amount positive", ok3 == false and err3 == "AmountMustBePositive")
end

return M
