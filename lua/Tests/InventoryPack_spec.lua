local T = require("Tests.TestUtils")
local Script = require("Packs.Inventory.Scripts.InventoryAcquirePulse")
local Actions = require("Packs.Inventory.Actions")

local M = {}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "InventoryAcquirePulse", script, ctx)
    T.AssertTrue("inventory success", r.Success)
    T.AssertEqual("inventory item count", ctx.Meta.Inventory["CraftPart_A"], 1)
    T.AssertEqual("inventory used", ctx.Meta.InventoryUsed, 1)

    ctx.Meta.InventoryCapacity = 1
    local r2 = T.RunScript(api, "InventoryAcquirePulse", script, ctx)
    T.AssertTrue("inventory fail expected", r2.Success == false)

    local ok1, err1 = Actions.AddItem(ctx, nil, 1)
    T.AssertTrue("item id required", ok1 == false and err1 == "ItemIdRequired")

    local ok2, err2 = Actions.AddItem(ctx, "CraftPart_A", 0)
    T.AssertTrue("count invalid", ok2 == false and err2 == "CountInvalid")

    local ok3, err3 = Actions.AddItem(ctx, "CraftPart_A", 10)
    T.AssertTrue("inventory overflow rejected", ok3 == false and err3 == "InventoryOverflow")

    local ok4, err4 = Actions.RemoveItem(ctx, "MissingItem", 1)
    T.AssertTrue("remove insufficient count", ok4 == false and err4 == "InsufficientItemCount")
end

return M
