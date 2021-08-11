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

    arpa2common-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "arpa2common";
      rev = "c65fbe034a288ba504b4b68b62b1546b8c3ddf5a";
      flake = false;
    };

    steamworks-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "steamworks";
      rev = "93935c899cd14b7659af0dbca05c776f7dc85ff4";
      flake = false;
    };

    steamworks-pulleyback-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "steamworks-pulleyback";
      rev = "f63d89ba54f3919fa9c67aab9d59efad3f2dc9c7";
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
          arpa2common =
            callPackage ./pkgs/arpa2common { src = inputs.arpa2common-src; };
          steamworks =
            callPackage ./pkgs/steamworks { src = inputs.steamworks-src; };
          steamworks-pulleyback = callPackage ./pkgs/steamworks-pulleyback {
            src = inputs.steamworks-pulleyback-src;
          };
        };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          arpa2cm arpa2common steamworks steamworks-pulleyback;
      });
    };
}
