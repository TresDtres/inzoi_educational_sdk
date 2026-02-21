# inZOI Modkit Educational SDK (UE5.6 + UnLua)

Educational architecture model for inZOI mods.

Important:
- This is not the official game API.
- This repository is a simulation built from observed documentation patterns.
- The goal is to teach robust technical design with UnLua.

## Architecture Layout

- `lua/Core`: context, result model, event bus, logger, script runner, and data registry.
- `lua/Conditions`: pure predicates (`bool`) with no side effects.
- `lua/Actions`: effectful commands (state changes, simulated UI/FX).
- `lua/Scripts`: orchestration layer.
- `lua/Examples`: bootstrap and end-to-end flow examples.

## Runtime Flow

1. UE creates the execution context (`Actor`, `Target`, `World`, metadata).
2. Lua evaluates `Conditions`.
3. If validation passes, `Actions` execute.
4. Events are emitted through `EventBus` for loose coupling.
5. `ScriptRunner` returns a structured `Result`.

## Quick Start (Educational)

1. Load `lua/Examples/Bootstrap.lua` with UnLua.
2. Execute `RunDemo()` to simulate the full pipeline.
3. Use `Scripts/Example_RelationshipBoost.lua` as a script template.
4. Run `lua/Examples/RunAllPacks.lua` to validate domain packs.
5. Run `lua/Tests/RunAllSpecs.lua` for automated tests.
6. Use `tools/generate_domain_pack.py` to scaffold new packs.

## Conventions

- `Condition`: pure function (`return bool, reason`).
- `Action`: effectful function (`return bool, reason`).
- `Script`: orchestration only; no infrastructure internals.
- `Result`: structured traceability for debugging.

## Engineering Guidelines

- One script, one gameplay intent.
- Validate `nil` and input data before acting.
- Keep side effects out of conditions.
- Emit stable, minimal event payloads.

## Common Anti-Patterns

- Mixing validation and execution.
- Actions with no partial-failure handling.
- Direct UI coupling inside domain logic.

## Pack Template

Base scaffold for new domain packs:

- `lua/Packs/PackTemplate/Conditions.lua`
- `lua/Packs/PackTemplate/Actions.lua`
- `lua/Packs/PackTemplate/Scripts/TemplatePulse.lua`

## JSON Output for CI

Export test results to JSON:

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua inzoi_educational_sdk\artifacts\test_report.json
```

You can also use an environment variable:

```powershell
$env:EDUSDK_TEST_JSON='inzoi_educational_sdk\artifacts\test_report.json'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua
```

## Domain Pack Generator

```powershell
python inzoi_educational_sdk\tools\generate_domain_pack.py --name Economy --with-test
```

This generates:
- `lua/Packs/Economy/Conditions.lua`
- `lua/Packs/Economy/Actions.lua`
- `lua/Packs/Economy/Scripts/EconomyPulse.lua`
- `lua/Tests/Economy_spec.lua` (when using `--with-test`)

## Internationalization (i18n)

Included locales:
- `lua/i18n/locales/en.lua`
- `lua/i18n/locales/es.lua`
- `lua/i18n/locales/de.lua`
- `lua/i18n/locales/fr.lua`
- `lua/i18n/locales/pt_br.lua`
- `lua/i18n/locales/kor.lua`
- `lua/i18n/locales/ja.lua`
- `lua/i18n/locales/zh_cn.lua`
- `lua/i18n/locales/index.lua` (central registry)

Runtime usage:

```lua
local api = require("EduAPI").NewRuntime({ locale = "de" })
print(api.I18n:T("course.title"))
api.I18n:SetLocale("es")
print(api.I18n:T("course.module.execution"))
```

Quick demo:

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua -e "require('Examples.I18nDemo').Run('Anna','de')"
```

### Optional `.po` Support

Convert a basic `.po` file into a Lua locale module:

```powershell
python inzoi_educational_sdk\tools\po_to_locale.py --po .\de.po --out inzoi_educational_sdk\lua\i18n\locales\de.lua
```

### Scale to Additional Languages

1. Create a locale scaffold from `en`:

```powershell
python inzoi_educational_sdk\tools\add_locale.py --code it --module it
```

2. Register the locale in `lua/i18n/locales/index.lua`:

```lua
{ code = "it", module = "i18n.locales.it" },
```

3. Validate key coverage for CI:

```powershell
python inzoi_educational_sdk\tools\check_locales.py --json-out inzoi_educational_sdk\artifacts\locales_report.json
```
