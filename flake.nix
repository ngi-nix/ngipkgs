rec {
  description =
    "Development projects for InternetWide.org, which builds a modern (domain) hosting stack intended to make users once more first-class citizens of the Internet.";

  outputs = { self, nixpkgs, ... }@args:
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
        nixpkgs.lib.composeManyExtensions [
          args.poetry2nix.overlay
          self.overlays.arpa2-packages
        ] final prev;

      overlays = {
        arpa2-packages = import ./overlays/arpa2-packages inputs args;
        arpa2-python-packages =
          import ./overlays/arpa2-python-packages inputs args;
      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          arpa2cm arpa2common steamworks quick-mem quick-der lillydap leaf
          quick-sasl tlspool tlspool-gui kip freeDiameter steamworks-pulleyback;
      });

      checks = forAllSystems (system: {
        inherit (nixpkgsFor.${system})
          arpa2cm arpa2common steamworks steamworks-pulleyback quick-mem
          quick-der lillydap leaf quick-sasl tlspool tlspool-gui freeDiameter
          kip;
      });
    };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix.url = "github:nix-community/poetry2nix";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    arpa2cm-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "arpa2cm";
      ref = "v0.9.0";
      flake = false;
    };

    arpa2common-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "arpa2common";
      ref = "v2.2.14";
      flake = false;
    };

    steamworks-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "steamworks";
      ref = "v0.97.2";
      flake = false;
    };

    steamworks-pulleyback-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "steamworks-pulleyback";
      ref = "v0.3.0";
      flake = false;
    };

    quick-mem-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "quick-mem";
      ref = "v0.2.2";
      flake = false;
    };

    quick-der-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "quick-der";
      ref = "v1.6.2";
      flake = false;
    };

    lillydap-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "lillydap";
      ref = "v0.9.2";
      flake = false;
    };

    leaf-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "leaf";
      ref = "master";
      flake = false;
    };

    quick-sasl-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "quick-sasl";
      ref = "v0.11.0";
      flake = false;
    };

    tlspool-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "tlspool";
      ref = "v0.9.6";
      flake = false;
    };

    tlspool-gui-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "tlspool-gui";
      ref = "v0.0.6";
      flake = false;
    };

    kip-src = {
      type = "gitlab";
      owner = "arpa2";
      repo = "kip";
      ref = "master";
      flake = false;
    };

    freeDiameter-src = {
      type = "github";
      owner = "freeDiameter";
      repo = "freeDiameter";
      ref = "master";
      flake = false;
    };
  };
}
