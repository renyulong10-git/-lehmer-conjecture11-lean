#!/usr/bin/env python3
"""Independent polynomial division check and Lean/JSON table comparison."""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
MODULUS = (1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1)


def advance(state, digit):
    polynomial = [digit, *state]
    leading = polynomial[10]
    return tuple(polynomial[i] - leading * MODULUS[i] for i in range(10))


def unique_object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError(f"duplicate JSON state: {key}")
        result[key] = value
    return result


def verify():
    raw = (ROOT / "completion_paths.json").read_bytes()
    paths = json.loads(raw, object_pairs_hook=unique_object)
    assert len(paths) == 1705
    for key, suffix in paths.items():
        state = tuple(map(int, key.split(",")))
        assert len(state) == 10
        assert all(type(d) is int and d in (-1, 0, 1) for d in suffix)
        for digit in suffix:
            state = advance(state, digit)
        assert state == (0,) * 10, f"nonzero terminal state: {key}"
    source = (ROOT / "Lehmer" / "CompletionData.lean").read_text()
    table = {}
    for coefficients, suffix in re.findall(r"⟨⟨([^⟩]+)⟩, \[([^\]]*)\]⟩", source):
        key = ",".join(str(int(x)) for x in coefficients.split(","))
        assert key not in table
        table[key] = [
            {"neg": -1, "zero": 0, "pos": 1}[d]
            for d in re.findall(r"Digit\.(neg|zero|pos)", suffix)
        ]
    assert table == paths
    assert max(map(len, paths.values())) == 56
    print("PASS: 1705 distinct states, all paths end at zero, longest suffix 56")
    print("PASS: Lean and JSON tables agree exactly")
    print("SHA256:", hashlib.sha256(raw).hexdigest())


if __name__ == "__main__":
    verify()
