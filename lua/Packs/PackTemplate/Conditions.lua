local TemplateConditions = {}

function TemplateConditions.CanRun(ctx)
    if ctx and ctx.Actor and ctx.Actor.Id then
        return true, nil
    end
    return false, "MissingActor"
end

return TemplateConditions
