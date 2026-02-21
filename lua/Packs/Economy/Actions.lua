local EconomyActions = {}

function EconomyActions.MarkExecuted(ctx, key)
    ctx.Meta = ctx.Meta or {}
    ctx.Meta.EconomyFlags = ctx.Meta.EconomyFlags or {}
    ctx.Meta.EconomyFlags[key or "Default"] = true
    return true, nil
end

return EconomyActions
