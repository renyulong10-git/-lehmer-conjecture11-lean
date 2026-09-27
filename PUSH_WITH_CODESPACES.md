# Publish the verified Phase A sources

Use this fallback only if the prepared commit cannot be pushed directly.
Open a Codespace for `renyulong10-git/-lehmer-conjecture11-lean` on `main` and
upload `lehmer_phaseA_rebuilt.zip`. The archive contains a top-level
`lehmer_phaseA_rebuilt/` folder; copy its contents into the repository root.
Review any existing changes before overwriting files.

```bash
unzip lehmer_phaseA_rebuilt.zip
cp -a lehmer_phaseA_rebuilt/. .
git status --short
python3 tools/verify_certificates.py
git add .github .gitignore AxiomAudit.lean Lehmer.lean Lehmer README.md \
  PUSH_WITH_CODESPACES.md VALIDATION_STATUS.md completion_paths.json \
  lake-manifest.json lakefile.lean lean-toolchain tools verification
git diff --cached --stat
git commit -m "Verify Lehmer Phase A certificates with independent checks"
git push origin main
```

The explicit staging list excludes the uploaded archive, extracted folder, and
build caches. Inspect the Actions run after pushing: every mandatory check must
succeed before claiming remote verification. See README.md for local checks.
