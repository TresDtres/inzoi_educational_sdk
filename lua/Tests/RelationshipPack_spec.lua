local T = require("Tests.TestUtils")
local Script = require("Packs.Relationship.Scripts.RelationshipDailyPulse")
local Actions = require("Packs.Relationship.Actions")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "RelationshipDailyPulse", script, ctx)
    T.AssertTrue("relationship success", r.Success)
    T.AssertEqual("relationship increment", ctx.Meta.Relationships["TestTarget"], 2)

    ctx.Meta.KnownTargets["TestTarget"] = nil
    local r2 = T.RunScript(api, "RelationshipDailyPulse", script, ctx)
    T.AssertTrue("relationship fail expected", r2.Success == false)

    local ok1, err1 = Actions.AddAffinity(ctx, nil, 1)
    T.AssertTrue("relationship nil target rejected", ok1 == false and err1 == "TargetRequired")

    local ok2, err2 = Actions.AddAffinity(ctx, "TestTarget", "x")
    T.AssertTrue("relationship invalid delta type rejected", ok2 == false and err2 == "DeltaMustBeNumber")

    local ok3, err3 = Actions.SetMainRelationship(ctx, "")
    T.AssertTrue("relationship empty target rejected", ok3 == false and err3 == "TargetRequired")
end

return M
