local EduAPI = require("EduAPI")
local Context = require("Core.Context")

local TestUtils = {}

function TestUtils.NewEnv(seedValue)
    local api = EduAPI.NewRuntime()
    local seed = seedValue or 0.5
    local ctx = Context.New({
        Actor = { Id = "TestActor" },
        Target = { Id = "TestTarget" },
        Stats = { Age = 20 },
        Buffs = {},
        Meta = {
            KnownTargets = { TestTarget = true },
            Relationships = { TestTarget = 1 },
            InventoryCapacity = 5,
            InventoryUsed = 0,
            Inventory = {},
            Quests = {},
        },
        RNG = function()
            return seed
        end,
    })
    return api, ctx
end

function TestUtils.AssertTrue(name, value)
    if not value then
        error("ASSERT_TRUE failed: " .. tostring(name))
    end
end

function TestUtils.AssertEqual(name, left, right)
    if left ~= right then
        error(string.format("ASSERT_EQUAL failed: %s (left=%s right=%s)", tostring(name), tostring(left), tostring(right)))
    end
end

function TestUtils.RunScript(api, id, scriptObj, ctx)
    return api.Runner:Run(id, scriptObj, ctx)
end

return TestUtils
