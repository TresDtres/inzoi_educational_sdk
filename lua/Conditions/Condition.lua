local Condition = {}

function Condition.AgeAtLeast(ctx, requiredAge)
    local age = ctx:GetStat("Age", 0)
    if age >= requiredAge then
        return true, nil
    end
    return false, "AgeTooLow"
end

function Condition.HasBuff(ctx, buffId)
    if ctx:HasBuff(buffId) then
        return true, nil
    end
    return false, "MissingBuff:" .. tostring(buffId)
end

function Condition.CheckDice(ctx, chance)
    local roll = ctx.RNG()
    if roll <= chance then
        return true, nil
    end
    return false, "DiceFailed"
end

function Condition.All(ctx, checkList)
    for _, fn in ipairs(checkList) do
        local ok, reason = fn()
        if not ok then
            return false, reason
        end
    end
    return true, nil
end

return Condition
