# inZOI Modkit Educational SDK (UE5.6 + UnLua)

Modelo educativo de arquitectura para mods de inZOI.

Importante:
- No es la API real del juego.
- Es una simulacion basada en patrones observados en la documentacion.
- Objetivo: ensenar diseno tecnico correcto en UnLua.

## Estructura

- `lua/Core`: contexto, resultado, bus de eventos, logger, runner, registro de datos.
- `lua/Conditions`: predicados puros (`bool`) sin efectos secundarios.
- `lua/Actions`: comandos con efectos (`state change`, UI/FX simulados).
- `lua/Scripts`: scripts orquestadores.
- `lua/Examples`: arranque y ejemplo de flujo completo.

## Flujo arquitectonico

1. UE crea contexto (`Actor`, `Target`, `World`, metadatos).
2. Lua evalua `Conditions`.
3. Si validan, ejecuta `Actions`.
4. Se emiten eventos (`EventBus`) para desacoplar.
5. `ScriptRunner` devuelve `Result` estructurado.

## Uso rapido (educativo)

1. Carga `lua/Examples/Bootstrap.lua` con UnLua.
2. Ejecuta `RunDemo()` para simular pipeline.
3. Revisa `Scripts/Example_RelationshipBoost.lua` como plantilla.
4. Ejecuta `lua/Examples/RunAllPacks.lua` para validar packs por dominio.
5. Ejecuta `lua/Tests/RunAllSpecs.lua` para tests automatizados.
6. Usa `tools/generate_domain_pack.py` para crear nuevos packs rapidamente.

## Convenciones

- `Condition`: funciones puras (`return bool, reason`).
- `Action`: funciones con efecto (`return bool, reason`).
- `Script`: orquesta y no contiene detalles de infraestructura.
- `Result`: contiene trazabilidad para depuracion.

## Buenas practicas

- Un script, una intencion de gameplay.
- Validar `nil` y datos antes de actuar.
- Mantener side effects fuera de conditions.
- Emitir eventos con payload pequeno y estable.

## Errores frecuentes

- Mezclar validacion con ejecucion.
- Acciones sin control de fallo parcial.
- Acoplar UI directamente a logica de dominio.

## Pack Template

Base para crear nuevos dominios rapidamente:

- `lua/Packs/PackTemplate/Conditions.lua`
- `lua/Packs/PackTemplate/Actions.lua`
- `lua/Packs/PackTemplate/Scripts/TemplatePulse.lua`

## Salida JSON para CI

Puedes exportar resultados de tests a JSON:

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua inzoi_educational_sdk\artifacts\test_report.json
```

Tambien puedes usar variable de entorno:

```powershell
$env:EDUSDK_TEST_JSON='inzoi_educational_sdk\artifacts\test_report.json'
lua inzoi_educational_sdk\lua\Tests\RunAllSpecs.lua
```

## Domain Pack Generator

```powershell
python inzoi_educational_sdk\tools\generate_domain_pack.py --name Economy --with-test
```

Esto crea:
- `lua/Packs/Economy/Conditions.lua`
- `lua/Packs/Economy/Actions.lua`
- `lua/Packs/Economy/Scripts/EconomyPulse.lua`
- `lua/Tests/Economy_spec.lua` (si usas `--with-test`)

## Internacionalizacion (i18n)

Locales incluidos:
- `lua/i18n/locales/en.lua`
- `lua/i18n/locales/es.lua`
- `lua/i18n/locales/de.lua`
- `lua/i18n/locales/fr.lua`
- `lua/i18n/locales/pt_br.lua`
- `lua/i18n/locales/kor.lua`
- `lua/i18n/locales/ja.lua`
- `lua/i18n/locales/zh_cn.lua`
- `lua/i18n/locales/index.lua` (registro central)

Uso en runtime:

```lua
local api = require("EduAPI").NewRuntime({ locale = "de" })
print(api.I18n:T("course.title"))
api.I18n:SetLocale("es")
print(api.I18n:T("course.module.execution"))
```

Demo rapido:

```powershell
$env:LUA_PATH='inzoi_educational_sdk\lua\?.lua;inzoi_educational_sdk\lua\?\init.lua;inzoi_educational_sdk\lua\?\?.lua;inzoi_educational_sdk\lua\?\?\?.lua;;'
lua -e "require('Examples.I18nDemo').Run('Anna','de')"
```

### Soporte opcional para archivos .po

Puedes convertir un `.po` basico a locale Lua:

```powershell
python inzoi_educational_sdk\tools\po_to_locale.py --po .\de.po --out inzoi_educational_sdk\lua\i18n\locales\de.lua
```

### Escalar a mas idiomas

1. Crea un locale base desde `en`:

```powershell
python inzoi_educational_sdk\tools\add_locale.py --code it --module it
```

2. Registra el locale en `lua/i18n/locales/index.lua`:

```lua
{ code = "it", module = "i18n.locales.it" },
```

3. Valida cobertura de claves para CI:

```powershell
python inzoi_educational_sdk\tools\check_locales.py --json-out inzoi_educational_sdk\artifacts\locales_report.json
```
