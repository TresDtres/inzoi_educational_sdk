local T = require("Tests.TestUtils")
local Script = require("Packs.Buff.Scripts.BuffLifecyclePulse")
local Actions = require("Packs.Buff.Actions")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "BuffLifecyclePulse", script, ctx)
    T.AssertTrue("buff add success", r.Success)
    T.AssertTrue("buff added", ctx.Buffs["Focused"] == true)

    local r2 = T.RunScript(api, "BuffLifecyclePulse", script, ctx)
    T.AssertTrue("buff remove success", r2.Success)
    T.AssertTrue("buff removed", ctx.Buffs["Focused"] == nil)

    local ok1, err1 = Actions.AddTimedBuff(ctx, nil, 10)
    T.AssertTrue("buff id required", ok1 == false and err1 == "BuffIdRequired")

    local ok2, err2 = Actions.AddTimedBuff(ctx, "Focused", 0)
    T.AssertTrue("buff duration invalid", ok2 == false and err2 == "DurationInvalid")

    local ok3, err3 = Actions.RemoveBuff(ctx, "")
    T.AssertTrue("remove buff invalid id", ok3 == false and err3 == "BuffIdRequired")
end

return M
