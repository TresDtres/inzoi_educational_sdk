# Domain Packs (Educational)

This SDK includes 4 vertical packs:

- `RelationshipPack`
- `QuestPack`
- `BuffPack`
- `InventoryPack`

Each pack contains:

- Domain conditions (pure predicates).
- Domain actions (controlled state mutations).
- An example orchestration script.

Objective: teach bounded-context composition with UnLua.

## Run Pack Demo

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua -e "require('Examples.RunAllPacks').Run()"
```

## Run Tests

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua
```

## Export JSON Report (CI)

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua inzoi_educational_sdk\artifacts\test_report.json
```

## Generate a New Domain from Template

```powershell
python inzoi_educational_sdk\tools\generate_domain_pack.py --name Economy --with-test
```

After generating a new test, add it to `lua/Tests/RunAllSpecs.lua`.

## i18n for Multi-Language Courses

You can change the active language at runtime using `EduAPI.NewRuntime({ locale = "de" })`.

Key-based translations:
- `api.I18n:T("course.title")`
- `api.I18n:T("course.module.struct")`

Default locales:
- `lua/i18n/locales/en.lua`
- `lua/i18n/locales/es.lua`
- `lua/i18n/locales/de.lua`
- `lua/i18n/locales/fr.lua`
- `lua/i18n/locales/pt_br.lua`
- `lua/i18n/locales/kor.lua`
- `lua/i18n/locales/ja.lua`
- `lua/i18n/locales/zh_cn.lua`
- `lua/i18n/locales/index.lua`

Recommended scale path:
1. Use `tools/add_locale.py` to create a new base locale.
2. Register the locale in `locales/index.lua`.
3. Use `tools/check_locales.py` to validate key coverage in CI.
