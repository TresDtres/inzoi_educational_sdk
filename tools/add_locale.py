#!/usr/bin/env python3
"""
Crea un nuevo locale Lua desde en.lua con prefijo TODO.

Ejemplo:
  python inzoi_educational_sdk/tools/add_locale.py --code it --module it
  python inzoi_educational_sdk/tools/add_locale.py --code ja --module ja
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def parse_lua_locale(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(r'\["([^"]+)"\]\s*=\s*"([^"]*)"\s*,?')
    return {m.group(1): m.group(2) for m in pattern.finditer(text)}


def main() -> None:
    p = argparse.ArgumentParser(description="Crea locale nuevo desde en.lua")
    p.add_argument("--code", required=True, help="Codigo locale visible (ej: it, ja, nl, pl)")
    p.add_argument("--module", required=True, help="Nombre de modulo archivo (ej: it, ja, pt_br)")
    p.add_argument("--sdk-root", default="inzoi_educational_sdk", help="Ruta del SDK")
    args = p.parse_args()

    sdk_root = Path(args.sdk_root).resolve()
    locales_dir = sdk_root / "lua" / "i18n" / "locales"
    en_path = locales_dir / "en.lua"
    out_path = locales_dir / f"{args.module}.lua"

    if out_path.exists():
        raise SystemExit(f"Locale ya existe: {out_path}")

    base = parse_lua_locale(en_path)
    lines = ["return {"]
    for k in sorted(base.keys()):
        v = base[k].replace("\\", "\\\\").replace('"', '\\"')
        lines.append(f'    ["{k}"] = "TODO({args.code}): {v}",')
    lines.append("}")
    lines.append("")
    out_path.write_text("\n".join(lines), encoding="utf-8")

    print(f"[DONE] Locale creado: {out_path}")
    print("[INFO] Agrega su entrada en lua/i18n/locales/index.lua")


if __name__ == "__main__":
    main()
