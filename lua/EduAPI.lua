local Context = require("Core.Context")
local EventBus = require("Core.EventBus")
local I18n = require("Core.I18n")
local Logger = require("Core.Logger")
local Registry = require("Core.Registry")
local ScriptRunner = require("Core.ScriptRunner")
local LocaleIndex = require("i18n.locales.index")

local Condition = require("Conditions.Condition")
local Action = require("Actions.Action")

local EduAPI = {}

function EduAPI.NewRuntime(opts)
    opts = opts or {}
    local eventBus = EventBus.New()
    local i18n = I18n.New({
        locale = opts.locale or "en",
        fallback_locale = "en",
    })
    for _, item in ipairs(LocaleIndex) do
        i18n:RegisterLocale(item.code, require(item.module))
    end

    local logger = Logger.New("[inZOI-EduSDK]", i18n)
    local registry = Registry.New()
    local runner = ScriptRunner.New({
        EventBus = eventBus,
        Logger = logger,
    })

    return {
        Context = Context,
        EventBus = eventBus,
        I18n = i18n,
        Logger = logger,
        Registry = registry,
        Runner = runner,
        Condition = Condition,
        Action = Action,
    }
end

return EduAPI
