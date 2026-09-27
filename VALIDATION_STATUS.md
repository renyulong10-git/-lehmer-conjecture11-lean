# Phase A validation — 2026-09-27

## Verified locally

| Check | Observed result |
| --- | --- |
| `lake build` | Passed, 742 build jobs |
| Independent polynomial certificate verifier | 1705 distinct entries, all terminal states zero; exact JSON/Lean agreement; maximum suffix length 56 |
| `lake env leanchecker -v Lehmer` | Passed; replayed all five project modules |
| Pinned axiom-audit v0.1.2 | Passed: all 194 declarations under `Lehmer` within `propext,Classical.choice,Quot.sound` |
| Pinned nanoda v0.4.19 | Passed: all 28 explicit project theorems and dependency closure, 1779 declarations, no errors |
| `lake env lean AxiomAudit.lean` | All 18 certificate chunk proofs and the 1705-entry count have no axioms |

Nanoda's actually admitted axioms were `propext` and `Quot.sound`. Its hard
allowlist also permits `Classical.choice`. Neither checker admits `sorryAx`
or compiler-trust axioms. Nanoda targets are enumerated from the four source
modules with an explicit module inventory and theorem count check.

Small original logs are included in `verification/`. These are local observations,
not remote GitHub Actions results. This cloud container required an environment-only
explicit-executable-path startup shim because its `/proc/<pid>/exe` lookup is
unavailable. The shim does not modify Lean, proof terms, or checker sources and
is not included in the project. A clean GitHub runner remains to be confirmed.

## Reproducibility pins

- Lean v4.34.1: `5045d0056413266e57c625dcd7c365b10e377c52`
- mathlib v4.34.1: `d13f23b723b8a846827a245b89c10fc7d3f11612`
- lean-action: `50fcf42d2e460296f1a34b402e990d1b24f8b596`
- axiom-audit v0.1.2: `46024e005996495c65ef609368e11ab39c4222e3`
- lean4export: `66f1fb4bc256072069767fce52d39480e4524869`
- nanoda: `3a2407216ee84a75f9e1aead6803d0578be06ae7`
- Original `completion_paths.json` SHA-256:
  `f6f60033bb45647cd175fad34227014fefaaea402ff904f4fe48e5c1c71f2778`

The old nanoda debug branch invoked by lean-action cannot parse the exporter's
NDJSON 3.1 format. CI therefore runs a separate mandatory script using the
format-compatible pinned checker. No verification gate is skipped.

## Scope and remaining work

The aggregate theorem checks every listed certificate; the member theorems
establish zero terminal state and the corresponding algebraic identity for
any table member. This does not prove that all relevant states occur in the table.

Core enumeration coverage, safe contraction, spectral density/Feng arguments,
Myhill–Nerode, and the full nonregularity conclusion of Conjecture 11 remain
unformalized. Phase A must not be described as a proof of the full conjecture.

GitHub connector writes returned HTTP 403 in this session. No remote CI success
has been observed.
