# Packs por Dominio (Educativos)

Este SDK incluye 4 packs verticales:

- `RelationshipPack`
- `QuestPack`
- `BuffPack`
- `InventoryPack`

Cada pack contiene:

- Conditions de dominio (predicados puros).
- Actions de dominio (mutaciones controladas).
- Script orquestador de ejemplo.

Objetivo: ensenar composicion por bounded context con UnLua.

## Ejecutar demo de packs

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua -e "require('Examples.RunAllPacks').Run()"
```

## Ejecutar tests

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua
```

## Exportar reporte JSON (CI)

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua inzoi_educational_sdk\artifacts\test_report.json
```

## Generar nuevo dominio desde template

```powershell
python inzoi_educational_sdk\tools\generate_domain_pack.py --name Economy --with-test
```

Despues de generar un test nuevo, agregalo a `lua/Tests/RunAllSpecs.lua`.

## I18n para curso multilenguaje

Puedes cambiar el idioma activo en runtime usando `EduAPI.NewRuntime({ locale = "de" })`.

Traducciones por clave:
- `api.I18n:T("course.title")`
- `api.I18n:T("course.module.struct")`

Locales por defecto:
- `lua/i18n/locales/en.lua`
- `lua/i18n/locales/es.lua`
- `lua/i18n/locales/de.lua`
- `lua/i18n/locales/fr.lua`
- `lua/i18n/locales/pt_br.lua`
- `lua/i18n/locales/kor.lua`
- `lua/i18n/locales/ja.lua`
- `lua/i18n/locales/zh_cn.lua`
- `lua/i18n/locales/index.lua`

Escalado recomendado:
1. `tools/add_locale.py` para crear nuevo idioma base.
2. Registrar idioma en `locales/index.lua`.
3. `tools/check_locales.py` para validar cobertura en CI.
