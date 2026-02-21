--[[
Bad Pattern: Stateful condition

Why this is wrong:
- Conditions must be pure evaluators.
- Mutating state in a condition causes hidden side effects.
- The same condition call can change future outcomes unpredictably.

Correct approach:
- Keep conditions read-only.
- Move all mutations into Actions.
]]

local M = {}

function M.CanRun(ctx)
    -- INTENTIONALLY INCORRECT:
    -- Condition mutates state (hidden side effect).
    ctx.Meta = ctx.Meta or {}
    ctx.Meta.Counter = (ctx.Meta.Counter or 0) + 1

    -- Evaluation is now coupled to mutation history, which is not acceptable.
    return ctx.Meta.Counter < 3
end

return M
