local InventoryActions = {}

function InventoryActions.AddItem(ctx, itemId, count)
    if type(itemId) ~= "string" or itemId == "" then
        return false, "ItemIdRequired"
    end
    count = count or 1
    if type(count) ~= "number" or count <= 0 then
        return false, "CountInvalid"
    end
    local cap = ctx.Meta.InventoryCapacity
    local used = ctx.Meta.InventoryUsed or 0
    if type(cap) == "number" and (used + count) > cap then
        return false, "InventoryOverflow"
    end
    ctx.Meta.Inventory = ctx.Meta.Inventory or {}
    ctx.Meta.Inventory[itemId] = (ctx.Meta.Inventory[itemId] or 0) + count
    ctx.Meta.InventoryUsed = used + count
    return true, nil
end

function InventoryActions.RemoveItem(ctx, itemId, count)
    if type(itemId) ~= "string" or itemId == "" then
        return false, "ItemIdRequired"
    end
    count = count or 1
    if type(count) ~= "number" or count <= 0 then
        return false, "CountInvalid"
    end
    ctx.Meta.Inventory = ctx.Meta.Inventory or {}
    local cur = ctx.Meta.Inventory[itemId] or 0
    if cur < count then
        return false, "InsufficientItemCount"
    end
    ctx.Meta.Inventory[itemId] = cur - count
    ctx.Meta.InventoryUsed = math.max(0, (ctx.Meta.InventoryUsed or 0) - count)
    return true, nil
end

return InventoryActions
