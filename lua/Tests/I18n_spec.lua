local T = require("Tests.TestUtils")
local EduAPI = require("EduAPI")

local M = {}

function M.Run()
    local api = EduAPI.NewRuntime({ locale = "de" })
    local v = api.I18n:T("course.module.struct")
    T.AssertEqual("de translation", v, "StructGuide Grundlagen")

    local changed = api.I18n:SetLocale("es")
    T.AssertTrue("set locale es", changed == true)
    T.AssertEqual("es translation", api.I18n:T("course.title"), "SDK educativo de inZOI Modkit")

    local changedFr = api.I18n:SetLocale("fr")
    T.AssertTrue("set locale fr", changedFr == true)
    T.AssertEqual("fr translation", api.I18n:T("course.module.execution"), "Modeles Script Execution")

    local changedPt = api.I18n:SetLocale("pt-BR")
    T.AssertTrue("set locale pt-br", changedPt == true)
    T.AssertEqual("pt-br translation", api.I18n:T("course.module.condition"), "Padroes de Script Condition")

    local changedKor = api.I18n:SetLocale("kor")
    T.AssertTrue("set locale kor", changedKor == true)
    T.AssertEqual("kor translation", api.I18n:T("course.module.struct"), "StructGuide 기초")

    local changedKo = api.I18n:SetLocale("ko")
    T.AssertTrue("set locale ko alias", changedKo == true)
    T.AssertEqual("ko alias translation", api.I18n:T("course.title"), "inZOI Modkit 교육용 SDK")

    local changedJa = api.I18n:SetLocale("ja")
    T.AssertTrue("set locale ja", changedJa == true)
    T.AssertEqual("ja translation", api.I18n:T("course.module.execution"), "Script Execution パターン")

    local changedZh = api.I18n:SetLocale("zh-CN")
    T.AssertTrue("set locale zh-cn", changedZh == true)
    T.AssertEqual("zh-cn translation", api.I18n:T("course.module.struct"), "StructGuide 基础")

    local changedZhAlias = api.I18n:SetLocale("zh")
    T.AssertTrue("set locale zh alias", changedZhAlias == true)
    T.AssertEqual("zh alias translation", api.I18n:T("course.title"), "inZOI Modkit 教学 SDK")

    local changedUnsupported = api.I18n:SetLocale("it")
    T.AssertTrue("unsupported locale returns false", changedUnsupported == false)

    local fallback = api.I18n:T("unknown.key")
    T.AssertEqual("unknown fallback key format", fallback, "[unknown.key]")
end

return M
