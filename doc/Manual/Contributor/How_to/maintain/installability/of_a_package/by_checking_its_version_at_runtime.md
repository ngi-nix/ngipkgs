# How to maintain installability of a package by checking its version at runtime {#Contributor_How_to_maintain_installability_of_a_package_by_checking_its_version_at_runtime}

With [versioncheckHook](https://nixos.org/manual/nixpkgs/unstable/#versioncheckhook):
```nix
mkDerivation {
  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgram = "${placeholder "out"}/bin/some-program";
  versionCheckProgramArg = "--version";
}
```
