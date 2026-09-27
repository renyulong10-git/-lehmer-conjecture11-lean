# Lehmer Conjecture 11 — Phase A certificates

Lean 4.34.1 / mathlib v4.34.1. This is a partial formalization, not the complete
Conjecture 11 proof. See [VALIDATION_STATUS.md](VALIDATION_STATUS.md) for evidence
and remaining proof obligations.

The project contains exact ten-coordinate state arithmetic, its algebraic
semantics, 1705 unchanged completion certificates, and aggregate/member theorems.

Prerequisites: elan/Lean, Git, Python 3, and Rust/Cargo (the independent checker
was tested with Rust 1.98.1). Network access is needed to fetch pinned dependencies.

```bash
lake update
lake exe cache get Mathlib.Tactic.Ring
lake build
python3 tools/verify_certificates.py
lake env leanchecker -v Lehmer
bash tools/verify_nanoda.sh
lake env lean AxiomAudit.lean
```

`AxiomAudit.lean` prints theorem dependencies; the mandatory CI `axiom-audit`
step enforces the allowlist `propext,Classical.choice,Quot.sound` across the
project namespace. Nanoda independently enforces the same strict allowlist
while checking all 28 explicit Phase A theorems and their complete dependency
closure. Its sources and the exporter are pinned in `tools/verify_nanoda.sh`.
No `sorry`, `admit`, or `native_decide` is used in the project proofs.

The workflow runs on pushes, pull requests, and manual dispatch. Local success
does not establish that the workflow has run successfully on GitHub.
