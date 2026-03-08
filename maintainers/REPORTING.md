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

To generate a helper draft for announcing others of project completion:

* Announcements draft
```bash
  nix eval --impure --expr '(import ./. {}).hydrated-projects.<PROJECT_NAME>' --json | ./maintainers/mk-announcement.sh --name <PROJECT_NAME>
```

Make sure the passed <PROJECT_NAME> is a valid name by entering it in: [https://nlnet.nl/project/<PROJECT_NAME>/](https://nlnet.nl/project/PROJECT_NAME/)
