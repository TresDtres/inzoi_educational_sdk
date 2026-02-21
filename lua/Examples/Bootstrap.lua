local EduAPI = require("EduAPI")
local ExampleScript = require("Scripts.Example_RelationshipBoost")

local Bootstrap = {}

function Bootstrap.RunDemo()
    local api = EduAPI.NewRuntime()

    api.EventBus:Subscribe("OnScriptStarted", function(payload)
        api.Logger:Info("Script iniciado: " .. payload.ScriptId)
    end)

    api.EventBus:Subscribe("OnScriptFinished", function(payload)
        api.Logger:Info("Script finalizado: " .. payload.ScriptId .. " success=" .. tostring(payload.Success))
    end)

    api.EventBus:Subscribe("OnConditionFailed", function(payload)
        api.Logger:Warn("Condition failed: " .. tostring(payload.Reason))
    end)

    api.EventBus:Subscribe("RelationshipChanged", function(payload)
        api.Logger:Info("Relacion actualizada target=" .. payload.TargetId .. " delta=" .. tostring(payload.Delta))
    end)

    api.Registry:RegisterStruct("Trait", {
        Id = "string",
        Category = "string",
        ValuePoint = "number",
    })

    local ok, reason = api.Registry:ValidatePayload("Trait", {
        Id = "Brave",
        Category = "Personality",
        ValuePoint = 10,
    })
    api.Logger:Info("ValidatePayload Trait -> " .. tostring(ok) .. " reason=" .. tostring(reason))

    local ctx = api.Context.New({
        Actor = { Id = "Player_01" },
        Target = { Id = "NPC_Ally_07" },
        Stats = {
            Age = 24,
        },
        Buffs = {},
        Meta = {},
        RNG = function()
            return 0.42
        end,
    })

    local scriptObj = ExampleScript.New(api)
    local result = api.Runner:Run("Example_RelationshipBoost", scriptObj, ctx)

    api.Logger:Info("Resultado final success=" .. tostring(result.Success) .. " error=" .. tostring(result.Error))
    return result
end

return Bootstrap
