local T = require("Tests.TestUtils")
local Script = require("Packs.Economy.Scripts.EconomyPulse")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "EconomyPulse", script, ctx)
    T.AssertTrue("Economy success", r.Success)
    T.AssertTrue("Economy flag set", ctx.Meta.EconomyFlags["EconomyPulse"] == true)
end

return M
