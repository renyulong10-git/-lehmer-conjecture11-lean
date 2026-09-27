#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exporter_sha=66f1fb4bc256072069767fce52d39480e4524869
checker_sha=3a2407216ee84a75f9e1aead6803d0578be06ae7
if [[ -n "${LEHMER_VERIFY_WORK_DIR:-}" ]]; then
  work_dir="$LEHMER_VERIFY_WORK_DIR"
  mkdir -p "$work_dir"
else
  work_dir="$(mktemp -d "${TMPDIR:-/tmp}/lehmer-nanoda.XXXXXX")"
  trap 'rm -rf "$work_dir"' EXIT
fi

fetch_pinned() {
  local url="$1" dir="$2" revision="$3"
  if [[ ! -d "$dir/.git" ]]; then
    git init -q "$dir"
    git -C "$dir" remote add origin "$url"
    git -C "$dir" fetch --depth 1 origin "$revision"
    git -C "$dir" checkout --detach -q FETCH_HEAD
  fi
  [[ "$(git -C "$dir" rev-parse HEAD)" == "$revision" ]]
  git -C "$dir" diff --exit-code HEAD -- . ':!lean-toolchain'
}

fetch_pinned https://github.com/leanprover/lean4export.git "$work_dir/lean4export" "$exporter_sha"
fetch_pinned https://github.com/ammkrn/nanoda_lib.git "$work_dir/nanoda_lib" "$checker_sha"
cp lean-toolchain "$work_dir/lean4export/lean-toolchain"
(cd "$work_dir/lean4export" && lake build)
(cd "$work_dir/nanoda_lib" && cargo build --release --locked)

target_text="$(python3 tools/nanoda_targets.py)"
mapfile -t targets <<< "$target_text"
printf 'Exporting %s Phase A theorems and their complete dependency closure\n' "${#targets[@]}"
printf '%s\n' "$target_text"
lake env "$work_dir/lean4export/.lake/build/bin/lean4export" Lehmer -- "${targets[@]}" > "$work_dir/Lehmer.ndjson"
python3 - "$work_dir" <<'PY'
import json, pathlib, sys
work = pathlib.Path(sys.argv[1])
config = {
    "export_file_path": str(work / "Lehmer.ndjson"),
    "use_stdin": False,
    "permitted_axioms": ["propext", "Classical.choice", "Quot.sound"],
    "unpermitted_axiom_hard_error": True,
    "nat_extension": True,
    "string_extension": True,
    "print_success_message": True,
    "pp_to_stdout": True,
}
(work / "nanoda.json").write_text(json.dumps(config, indent=2))
print("Export bytes:", (work / "Lehmer.ndjson").stat().st_size)
print("Strict axiom allowlist:", config["permitted_axioms"])
PY
"$work_dir/nanoda_lib/target/release/nanoda_bin" "$work_dir/nanoda.json"
