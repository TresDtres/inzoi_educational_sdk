local InventoryConditions = {}

function InventoryConditions.HasCapacity(ctx, requiredSlots)
    local cap = ctx.Meta.InventoryCapacity or 0
    local used = ctx.Meta.InventoryUsed or 0
    if (used + requiredSlots) <= cap then
        return true, nil
    end
    return false, "NoCapacity"
end

function InventoryConditions.HasItem(ctx, itemId, minCount)
    local meta = ctx.Meta or {}
    local inventory = meta.Inventory or {}
    local count = inventory[itemId] or 0
    if count >= (minCount or 1) then
        return true, nil
    end
    return false, "MissingItem"
end

return InventoryConditions
