local EduAPI = require("EduAPI")
local Context = require("Core.Context")

local RelationshipScript = require("Packs.Relationship.Scripts.RelationshipDailyPulse")
local QuestScript = require("Packs.Quest.Scripts.QuestProgressPulse")
local BuffScript = require("Packs.Buff.Scripts.BuffLifecyclePulse")
local InventoryScript = require("Packs.Inventory.Scripts.InventoryAcquirePulse")

local Runner = {}

local function runOne(api, id, obj, ctx)
    local result = api.Runner:Run(id, obj, ctx)
    api.Logger:Info(string.format("PackRun id=%s success=%s steps=%d", id, tostring(result.Success), #result.Steps))
    return result
end

function Runner.Run()
    local api = EduAPI.NewRuntime()

    api.EventBus:Subscribe("RelationshipChanged", function(p)
        api.Logger:Info("Event RelationshipChanged target=" .. tostring(p.TargetId))
    end)
    api.EventBus:Subscribe("QuestUpdated", function(p)
        api.Logger:Info("Event QuestUpdated id=" .. tostring(p.QuestId))
    end)
    api.EventBus:Subscribe("InventoryChanged", function(p)
        api.Logger:Info("Event InventoryChanged item=" .. tostring(p.ItemId))
    end)

    local ctx = Context.New({
        Actor = { Id = "Player_01" },
        Target = { Id = "NPC_A" },
        Stats = { Age = 21 },
        Buffs = {},
        Meta = {
            KnownTargets = { NPC_A = true },
            Relationships = { NPC_A = 2 },
            InventoryCapacity = 20,
            InventoryUsed = 3,
            Inventory = {},
            Quests = {},
        },
        RNG = function()
            return 0.3
        end,
    })

    local results = {
        runOne(api, "RelationshipDailyPulse", RelationshipScript.New(api), ctx),
        runOne(api, "QuestProgressPulse", QuestScript.New(api), ctx),
        runOne(api, "BuffLifecyclePulse", BuffScript.New(api), ctx),
        runOne(api, "InventoryAcquirePulse", InventoryScript.New(api), ctx),
    }
    return results
end

return Runner
