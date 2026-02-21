#!/usr/bin/env python3
"""
Convierte un archivo .po sencillo (msgid/msgstr en una linea) a locale Lua.

Uso:
  python inzoi_educational_sdk/tools/po_to_locale.py \
    --po de.po \
    --out inzoi_educational_sdk/lua/i18n/locales/de.lua
"""

from __future__ import annotations

import argparse
import re
from pathlib import Path


def parse_po(path: Path) -> dict[str, str]:
    entries: dict[str, str] = {}
    current_id: str | None = None
    current_str: str | None = None

    for raw in path.read_text(encoding="utf-8", errors="ignore").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m_id = re.match(r'^msgid\s+"(.*)"$', line)
        if m_id:
            current_id = m_id.group(1)
            current_str = None
            continue
        m_str = re.match(r'^msgstr\s+"(.*)"$', line)
        if m_str and current_id is not None:
            current_str = m_str.group(1)
            entries[current_id] = current_str
            current_id = None
            current_str = None

    return entries


def to_lua_table(entries: dict[str, str]) -> str:
    lines = ["return {"]
    for key in sorted(entries.keys()):
        val = entries[key].replace("\\", "\\\\").replace('"', '\\"')
        k = key.replace("\\", "\\\\").replace('"', '\\"')
        lines.append(f'    ["{k}"] = "{val}",')
    lines.append("}")
    lines.append("")
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Convierte .po a locale Lua")
    parser.add_argument("--po", required=True, help="Ruta del archivo .po")
    parser.add_argument("--out", required=True, help="Ruta de salida .lua")
    args = parser.parse_args()

    po_path = Path(args.po).resolve()
    out_path = Path(args.out).resolve()
    out_path.parent.mkdir(parents=True, exist_ok=True)

    entries = parse_po(po_path)
    out_path.write_text(to_lua_table(entries), encoding="utf-8")
    print(f"[DONE] Locale generado con {len(entries)} entradas: {out_path}")


if __name__ == "__main__":
    main()
