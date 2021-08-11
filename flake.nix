{
  description =
    "Development projects for InternetWide.org, which builds a modern (domain) hosting stack intended to make users once more first-class citizens of the Internet.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    arpa2cm-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "arpa2cm";
      rev = "c3aa5b6ce5c3c14a66bbf27044c517186176cb66";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];

      # BEGIN Helper functions
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        });
      # END Helper functions
    in {
      overlay = final: prev:
        with final.pkgs; {
          arpa2cm = callPackage ./pkgs/arpa2cm { src = inputs.arpa2cm-src; };
        };

      packages =
        forAllSystems (system: { inherit (nixpkgsFor.${system}) arpa2cm; });
    };
}
