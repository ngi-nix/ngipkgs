# Reporting

Use following scripts to get baseline data for reporting:

* Repository metrics
```bash
  nix eval --option allow-import-from-derivation true --json -f default.nix metrics.summary | jq
```

* Packaging and repository content summary
```bash
  nix build --option allow-import-from-derivation true -f default.nix report.packaging
  cat ./result
```
