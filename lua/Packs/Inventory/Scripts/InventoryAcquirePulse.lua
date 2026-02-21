local Cond = require("Packs.Inventory.Conditions")
local Act = require("Packs.Inventory.Actions")

local Script = {}
Script.__index = Script

function Script.New(api)
    return setmetatable({ Api = api }, Script)
end

function Script:Execute(ctx, result)
    local itemId = "CraftPart_A"
    local ok1, r1 = Cond.HasCapacity(ctx, 1)
    result:AddStep("Condition", "HasCapacity", ok1, r1)
    if not ok1 then
        return false, r1
    end

    local ok2, r2 = Act.AddItem(ctx, itemId, 1)
    result:AddStep("Action", "AddItem", ok2, r2)
    if not ok2 then
        return false, r2
    end

    self.Api.EventBus:Emit("InventoryChanged", { ItemId = itemId, Delta = 1 })
    return true, nil
end

return Script
