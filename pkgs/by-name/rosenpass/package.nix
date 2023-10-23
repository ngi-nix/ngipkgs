{ pkgs, lib, nixosTests, ... }:
lib.recursiveUpdate pkgs.rosenpass {
  meta.ngi = {
    project = "Rosenpass";
    options = [["services" "rosenpass"]];
    main = true;
  };

  passthru.tests.rosenpass-sops = nixosTests.rosenpass;
}
