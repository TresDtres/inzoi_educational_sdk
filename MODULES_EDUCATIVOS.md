# Educational Modules (Simulated Model)

## Module: StructGuide Data

- Original wiki concept: `StructGuide` defines entities and fields.
- Technical interpretation: data contract for gameplay systems.
- Simulated educational API: `Core/Registry.lua`.
- Practical example: `Registry:ValidatePayload("Trait", payload)`.
- Internal flow: UE data -> Registry -> Lua script.
- Best practice: validate payloads before executing actions.
- Common failure mode: missing fields or invalid types.

## Module: Script Condition

- Original wiki concept: `[Cond]_...` conditions.
- Technical interpretation: authorization predicates.
- Simulated educational API: `Conditions/Condition.lua`.
- Practical example: `Condition.All(...)`.
- Internal flow: trigger -> check -> continue/cancel.
- Best practice: keep conditions pure and side-effect free.
- Common failure mode: mutating state during condition evaluation.

## Module: Script Execution

- Original wiki concept: `[Exec]_...` actions.
- Technical interpretation: mutation and presentation commands.
- Simulated educational API: `Actions/Action.lua`.
- Practical example: `Action.Sequence(...)`.
- Internal flow: condition success -> execute actions -> emit events.
- Best practice: enforce per-action partial-failure handling.
- Common failure mode: skipping target/parameter validation.
