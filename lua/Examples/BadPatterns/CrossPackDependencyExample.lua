--[[
Bad Pattern: Cross-pack direct dependency

Why this is wrong:
- A pack script directly requiring another pack creates tight coupling.
- It breaks bounded context isolation and increases regression risk.
- It makes packs non-portable and harder to test independently.

Correct approach:
- Keep pack dependencies internal.
- Coordinate cross-domain behavior via event bus or neutral orchestration layer.
]]

local M = {}

-- INTENTIONALLY INCORRECT:
-- This file represents a Relationship-oriented script directly importing Quest pack logic.
local QuestActions = require("Packs.Quest.Actions")

function M.Execute(ctx)
    -- INTENTIONALLY INCORRECT:
    -- Directly mutating quest state from another pack boundary.
    QuestActions.AcceptQuest(ctx, "CrossPackQuest")
    return true
end

return M
