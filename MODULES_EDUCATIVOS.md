# Modulos Educativos (modelo simulado)

## Modulo: StructGuide Data

- Concepto original de la wiki: `StructGuide` describe entidades y campos.
- Interpretacion tecnica: contrato de datos para sistemas de juego.
- API educativa simulada: `Core/Registry.lua`.
- Ejemplo practico: `Registry:ValidatePayload("Trait", payload)`.
- Flujo interno: UE data -> Registry -> script Lua.
- Buenas practicas: validar payload antes de ejecutar actions.
- Errores frecuentes: campos faltantes o tipos incorrectos.

## Modulo: Script Condition

- Concepto original de la wiki: condiciones `[Cond]_...`.
- Interpretacion tecnica: predicados de autorizacion.
- API educativa simulada: `Conditions/Condition.lua`.
- Ejemplo practico: `Condition.All(...)`.
- Flujo interno: trigger -> check -> continue/cancel.
- Buenas practicas: condiciones puras sin side effects.
- Errores frecuentes: mutar estado durante una condicion.

## Modulo: Script Execution

- Concepto original de la wiki: acciones `[Exec]_...`.
- Interpretacion tecnica: comandos de mutacion y presentacion.
- API educativa simulada: `Actions/Action.lua`.
- Ejemplo practico: `Action.Sequence(...)`.
- Flujo interno: condition success -> execute actions -> emit events.
- Buenas practicas: control de fallo parcial por accion.
- Errores frecuentes: no validar target o parametros.
