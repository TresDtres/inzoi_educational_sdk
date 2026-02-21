local Action = {}

local function addBuffLocal(ctx, buffId)
    ctx.Buffs[buffId] = true
end

function Action.AddBuff(ctx, buffId, duration)
    if not buffId then
        return false, "BuffIdRequired"
    end
    addBuffLocal(ctx, buffId)
    ctx.Meta.LastBuffDuration = duration
    return true, nil
end

function Action.SetRelationship(ctx, targetId, delta)
    if not targetId then
        return false, "TargetRequired"
    end
    ctx.Meta.Relationships = ctx.Meta.Relationships or {}
    local cur = ctx.Meta.Relationships[targetId] or 0
    ctx.Meta.Relationships[targetId] = cur + (delta or 0)
    return true, nil
end

function Action.PlayFX(ctx, fxId)
    if not fxId then
        return false, "FxIdRequired"
    end
    ctx.Meta.LastFX = fxId
    return true, nil
end

function Action.Sequence(ctx, actionList)
    for _, fn in ipairs(actionList) do
        local ok, reason = fn()
        if not ok then
            return false, reason
        end
    end
    return true, nil
end

return Action
