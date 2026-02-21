#!/usr/bin/env python3
"""
Valida cobertura de claves i18n contra en.lua.
Opcionalmente exporta reporte JSON para CI.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path


def parse_lua_locale(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    pattern = re.compile(r'\["([^"]+)"\]\s*=\s*"([^"]*)"\s*,?')
    return {m.group(1): m.group(2) for m in pattern.finditer(text)}


def load_index(path: Path) -> list[tuple[str, str]]:
    text = path.read_text(encoding="utf-8", errors="ignore")
    item_re = re.compile(r'\{\s*code\s*=\s*"([^"]+)"\s*,\s*module\s*=\s*"([^"]+)"\s*\}')
    return [(m.group(1), m.group(2)) for m in item_re.finditer(text)]


def main() -> None:
    p = argparse.ArgumentParser(description="Valida cobertura de locales")
    p.add_argument("--sdk-root", default="inzoi_educational_sdk")
    p.add_argument("--json-out", default="")
    args = p.parse_args()

    sdk = Path(args.sdk_root).resolve()
    locales_dir = sdk / "lua" / "i18n" / "locales"
    index_path = locales_dir / "index.lua"
    base = parse_lua_locale(locales_dir / "en.lua")
    base_keys = set(base.keys())

    report = {"ok": True, "base_locale": "en", "checks": []}
    items = load_index(index_path)
    for code, module in items:
        file_name = module.split(".")[-1] + ".lua"
        locale_path = locales_dir / file_name
        data = parse_lua_locale(locale_path)
        keys = set(data.keys())
        missing = sorted(base_keys - keys)
        extra = sorted(keys - base_keys)
        has_todo = sorted([k for k, v in data.items() if v.startswith("TODO(")])

        ok = len(missing) == 0
        if not ok:
            report["ok"] = False
        report["checks"].append(
            {
                "code": code,
                "file": str(locale_path),
                "missing": missing,
                "extra": extra,
                "todo_keys": has_todo,
                "ok": ok,
            }
        )

    if args.json_out:
        out = Path(args.json_out).resolve()
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"[INFO] JSON report: {out}")

    for item in report["checks"]:
        status = "PASS" if item["ok"] else "FAIL"
        print(f"[{status}] {item['code']} missing={len(item['missing'])} extra={len(item['extra'])} todo={len(item['todo_keys'])}")

    if not report["ok"]:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
