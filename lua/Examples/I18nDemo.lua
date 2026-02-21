local EduAPI = require("EduAPI")

local Demo = {}

function Demo.Run(studentName, localeCode)
    local api = EduAPI.NewRuntime({ locale = localeCode or "en" })
    api.Logger:InfoT("student.welcome", {
        name = studentName or "Student",
        locale = api.I18n.Locale,
    })
    api.Logger:Info(api.I18n:T("course.title"))
    api.Logger:Info(api.I18n:T("course.module.struct"))
    api.Logger:Info(api.I18n:T("course.module.condition"))
    api.Logger:Info(api.I18n:T("course.module.execution"))

    return true
end

return Demo
