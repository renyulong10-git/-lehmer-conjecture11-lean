#!/usr/bin/env python3
"""Enumerate every explicit Phase A theorem; fail if the module inventory changes."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
prefixes = {
    "Core.lean": "Lehmer.State",
    "Boundary.lean": "Lehmer",
    "CompletionData.lean": "Lehmer",
    "Completion.lean": "Lehmer",
}
if {str(p.relative_to(root / "Lehmer")) for p in (root / "Lehmer").rglob("*.lean")} != set(prefixes):
    raise SystemExit("Unexpected Lean module inventory")
targets = []
for filename, prefix in prefixes.items():
    source = (root / "Lehmer" / filename).read_text()
    names = re.findall(r"^theorem\s+([A-Za-z0-9_]+)", source, re.MULTILINE)
    if not names:
        raise SystemExit(f"No theorems found in {filename}")
    targets.extend(f"{prefix}.{name}" for name in names)
if not (len(targets) == len(set(targets)) == 28):
    raise SystemExit("Expected exactly 28 unique Phase A theorem names")
print("\n".join(targets))
