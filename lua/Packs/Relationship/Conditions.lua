local RelationshipConditions = {}

function RelationshipConditions.HasMinAffinity(ctx, targetId, minValue)
    local meta = ctx.Meta or {}
    local relationships = meta.Relationships or {}
    local cur = relationships[targetId] or 0
    if cur >= minValue then
        return true, nil
    end
    return false, "AffinityTooLow"
end

function RelationshipConditions.IsKnownTarget(ctx, targetId)
    local meta = ctx.Meta or {}
    local known_targets = meta.KnownTargets or {}
    if known_targets[targetId] == true then
        return true, nil
    end
    return false, "UnknownTarget"
end

return RelationshipConditions
