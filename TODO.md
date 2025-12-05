## Reaction

- [ ] Upstreaming to nixpkgs not ngipkgs
- [ ] modernize reaction package
  - [ ] also the module
    - eljamm's suggestion, replaceVars
- [ ] author's requests
  - [ ] build/eval time config validation
    - asked eljamm, said there is a `check` function for mkOption
    - I suggested instead of complex nix functions, why not do it in buildPhase?
      - Because jsonnet is not json
