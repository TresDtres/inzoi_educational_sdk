--[[
Bad Pattern: Script without validation

Why this is wrong:
- Orchestration without conditions executes actions on invalid context.
- It can mutate state with missing actor/target preconditions.
- Failures become runtime incidents instead of controlled outcomes.

Correct approach:
- Evaluate Conditions first.
- Execute Actions only after successful validation.
- Return structured failure information when validation fails.
]]

local M = {}

function M.Execute(ctx)
    -- INTENTIONALLY INCORRECT:
    -- No validation step, direct mutation path.
    ctx.Meta = ctx.Meta or {}
    ctx.Meta.Relationships = ctx.Meta.Relationships or {}

    local targetId = ctx.Target and ctx.Target.Id or nil

    -- INTENTIONALLY INCORRECT:
    -- If targetId is nil, this still attempts mutation and corrupts domain state.
    ctx.Meta.Relationships[targetId] = (ctx.Meta.Relationships[targetId] or 0) + 10

    return true
end

return M
