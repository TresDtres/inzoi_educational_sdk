local BuffActions = {}

function BuffActions.AddTimedBuff(ctx, buffId, duration)
    if type(buffId) ~= "string" or buffId == "" then
        return false, "BuffIdRequired"
    end
    if duration ~= nil and (type(duration) ~= "number" or duration <= 0) then
        return false, "DurationInvalid"
    end
    ctx.Buffs[buffId] = true
    ctx.Meta.BuffDuration = ctx.Meta.BuffDuration or {}
    ctx.Meta.BuffDuration[buffId] = duration or 60
    return true, nil
end

function BuffActions.RemoveBuff(ctx, buffId)
    if type(buffId) ~= "string" or buffId == "" then
        return false, "BuffIdRequired"
    end
    ctx.Buffs[buffId] = nil
    if ctx.Meta.BuffDuration then
        ctx.Meta.BuffDuration[buffId] = nil
    end
    return true, nil
end

return BuffActions
