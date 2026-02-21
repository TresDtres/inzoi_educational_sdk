local T = require("Tests.TestUtils")
local Script = require("Packs.PackTemplate.Scripts.TemplatePulse")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "TemplatePulse", script, ctx)
    T.AssertTrue("template success", r.Success)
    T.AssertTrue("template flag set", ctx.Meta.TemplateFlags["TemplatePulse"] == true)

    ctx.Actor = nil
    local r2 = T.RunScript(api, "TemplatePulse", script, ctx)
    T.AssertTrue("template fail expected", r2.Success == false)
end

return M
