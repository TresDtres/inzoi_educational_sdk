#!/usr/bin/env python3
"""
Genera un nuevo pack educativo de dominio para el SDK de inZOI.

Ejemplo:
  python inzoi_educational_sdk/tools/generate_domain_pack.py --name Economy
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def to_safe_pack_name(name: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9_]", "", name)
    if not cleaned:
        raise ValueError("El nombre del pack no puede quedar vacio.")
    if cleaned[0].isdigit():
        cleaned = f"Pack{cleaned}"
    return cleaned


def write_file(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def build_conditions(pack: str) -> str:
    return f"""local {pack}Conditions = {{}}

function {pack}Conditions.CanRun(ctx)
    if ctx and ctx.Actor and ctx.Actor.Id then
        return true, nil
    end
    return false, "MissingActor"
end

return {pack}Conditions
"""


def build_actions(pack: str) -> str:
    return f"""local {pack}Actions = {{}}

function {pack}Actions.MarkExecuted(ctx, key)
    ctx.Meta = ctx.Meta or {{}}
    ctx.Meta.{pack}Flags = ctx.Meta.{pack}Flags or {{}}
    ctx.Meta.{pack}Flags[key or "Default"] = true
    return true, nil
end

return {pack}Actions
"""


def build_script(pack: str, pulse_name: str) -> str:
    return f"""local Cond = require("Packs.{pack}.Conditions")
local Act = require("Packs.{pack}.Actions")

local Script = {{}}
Script.__index = Script

function Script.New(api)
    return setmetatable({{ Api = api }}, Script)
end

function Script:Execute(ctx, result)
    local ok, reason = Cond.CanRun(ctx)
    result:AddStep("Condition", "CanRun", ok, reason)
    if not ok then
        return false, reason
    end

    local ok2, reason2 = Act.MarkExecuted(ctx, "{pulse_name}")
    result:AddStep("Action", "MarkExecuted", ok2, reason2)
    if not ok2 then
        return false, reason2
    end

    self.Api.EventBus:Emit("{pack}Changed", {{ Key = "{pulse_name}" }})
    return true, nil
end

return Script
"""


def build_test(pack: str, pulse_name: str) -> str:
    return f"""local T = require("Tests.TestUtils")
local Script = require("Packs.{pack}.Scripts.{pulse_name}")

local M = {{}}

function M.Run()
    local api, ctx = T.NewEnv(0.1)
    local script = Script.New(api)

    local r = T.RunScript(api, "{pulse_name}", script, ctx)
    T.AssertTrue("{pack} success", r.Success)
    T.AssertTrue("{pack} flag set", ctx.Meta.{pack}Flags["{pulse_name}"] == true)
end

return M
"""


def main() -> None:
    parser = argparse.ArgumentParser(description="Genera un nuevo domain pack educativo")
    parser.add_argument("--name", required=True, help="Nombre del dominio (ej: Economy, Social, Crafting)")
    parser.add_argument(
        "--sdk-root",
        default="inzoi_educational_sdk",
        help="Ruta raiz del SDK educativo",
    )
    parser.add_argument(
        "--with-test",
        action="store_true",
        help="Genera tambien archivo de test base en lua/Tests",
    )
    args = parser.parse_args()

    pack = to_safe_pack_name(args.name)
    pulse_name = f"{pack}Pulse"
    sdk_root = Path(args.sdk_root).resolve()

    pack_root = sdk_root / "lua" / "Packs" / pack
    if pack_root.exists():
        raise SystemExit(f"El pack ya existe: {pack_root}")

    write_file(pack_root / "Conditions.lua", build_conditions(pack))
    write_file(pack_root / "Actions.lua", build_actions(pack))
    write_file(pack_root / "Scripts" / f"{pulse_name}.lua", build_script(pack, pulse_name))

    if args.with_test:
        write_file(sdk_root / "lua" / "Tests" / f"{pack}_spec.lua", build_test(pack, pulse_name))

    print(f"[DONE] Pack generado: {pack}")
    print(f"[INFO] Ruta: {pack_root}")
    if args.with_test:
        print(f"[INFO] Test base generado: {sdk_root / 'lua' / 'Tests' / (pack + '_spec.lua')}")
        print("[INFO] Recuerda registrar el spec en lua/Tests/RunAllSpecs.lua")


if __name__ == "__main__":
    main()
