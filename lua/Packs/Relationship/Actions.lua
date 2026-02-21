local RelationshipActions = {}

function RelationshipActions.SetMainRelationship(ctx, targetId)
    if type(targetId) ~= "string" or targetId == "" then
        return false, "TargetRequired"
    end
    ctx.Meta.MainRelationship = targetId
    return true, nil
end

function RelationshipActions.AddAffinity(ctx, targetId, delta)
    if type(targetId) ~= "string" or targetId == "" then
        return false, "TargetRequired"
    end
    if delta ~= nil and type(delta) ~= "number" then
        return false, "DeltaMustBeNumber"
    end
    ctx.Meta.Relationships = ctx.Meta.Relationships or {}
    local cur = ctx.Meta.Relationships[targetId] or 0
    ctx.Meta.Relationships[targetId] = cur + (delta or 0)
    return true, nil
end

return RelationshipActions
