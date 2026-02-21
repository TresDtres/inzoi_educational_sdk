local TemplateActions = {}

function TemplateActions.MarkExecuted(ctx, key)
    ctx.Meta = ctx.Meta or {}
    ctx.Meta.TemplateFlags = ctx.Meta.TemplateFlags or {}
    ctx.Meta.TemplateFlags[key or "Default"] = true
    return true, nil
end

return TemplateActions
