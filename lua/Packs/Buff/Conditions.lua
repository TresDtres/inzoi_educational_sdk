local BuffConditions = {}

function BuffConditions.HasBuff(ctx, buffId)
    if ctx:HasBuff(buffId) then
        return true, nil
    end
    return false, "MissingBuff"
end

function BuffConditions.CanAddBuff(ctx, buffId)
    if ctx:HasBuff(buffId) then
        return false, "AlreadyPresent"
    end
    return true, nil
end

return BuffConditions
