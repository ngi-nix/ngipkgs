rec {
  description = "Development projects for InternetWide.org, which builds a modern (domain) hosting stack intended to make users once more first-class citizens of the Internet.";

  outputs = {
    self,
    nixpkgs,
    ...
  } @ args: let
    supportedSystems = ["x86_64-linux"];

    # BEGIN Helper functions
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system: f system);

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [self.overlay];
      });
    # END Helper functions
  in {
    overlay = final: prev:
      nixpkgs.lib.composeManyExtensions [
        self.overlays.arpa2-packages
      ]
      final
      prev;

    overlays = {
      arpa2-packages = import ./overlays/arpa2-packages inputs args;
    };

    packages = forAllSystems (system: {
      inherit
        (nixpkgsFor.${system})
        steamworks
        lillydap
        leaf
        quicksasl
        tlspool
        tlspool-gui
        kip
        freeDiameter
        steamworks-pulleyback
        ;
    });

    checks = forAllSystems (system: {
      inherit
        (nixpkgsFor.${system})
        steamworks
        steamworks-pulleyback
        lillydap
        leaf
        quicksasl
        tlspool
        tlspool-gui
        freeDiameter
        kip
        ;
    });
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/44881e03af1c730cbb1d72a4d41274a2c957813a";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
}
