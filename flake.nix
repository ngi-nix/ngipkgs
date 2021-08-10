{
  description = "(insert short project description here)";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  # Upstream source tree(s).
  inputs.ipfs-search-backend-src = { url = "github:ipfs-search/ipfs-search"; flake = false; };
  inputs.npmlock2nix-src = { url = "github:tweag/npmlock2nix"; flake = false; };
  inputs.ipfs-search-frontend-src = { url = "github:ipfs-search/dweb-search-frontend"; flake = false; };

  outputs = { self, nixpkgs, ipfs-search-backend-src, npmlock2nix-src, ipfs-search-frontend-src }:
    let
      # Generate a user-friendly version numer.
      userFriendlyVersion = src: builtins.substring 0 8 src.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev: {

        ipfs-search-backend = with final; buildGo115Module rec {
          pname = "ipfs-search-backend";
          version = userFriendlyVersion src;

          vendorSha256 = "sha256-bz427bRS0E1xazQuSC7GqHSD5yBBrDv8o22TyVJ6fho=";
          src = ipfs-search-backend-src;

          meta = {
            license = with final.lib.licenses; agpl3Only;
            homepage = "https://ipfs-search.com";
            description = "Search engine for the Interplanetary Filesystem.";
          };
        };

        ipfs-search-frontend =
          let
            npmlock2nix = final.callPackage npmlock2nix-src { };
          in
          npmlock2nix.build {
            src = ipfs-search-frontend-src;
            installPhase = "cp -r dist $out";
            buildCommands = [ "npm run build" ];
          };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) ipfs-search-backend ipfs-search-frontend;
        });


      # A NixOS module, if applicable (e.g. if the package provides a system service).
      # nixosModules.hello =
      #   { pkgs, ... }:
      #   {
      #     nixpkgs.overlays = [ self.overlay ];

      #     environment.systemPackages = [ pkgs.hello ];

      #     #systemd.services = { ... };
      #   };

      # Tests run by 'nix flake check' and by Hydra.
      # checks = forAllSystems (system: {
      #   inherit (self.packages.${system}) hello;

      #   # Additional tests, if applicable.
      #   test =
      #     with nixpkgsFor.${system};
      #     stdenv.mkDerivation {
      #       name = "hello-test-${version}";

      #       buildInputs = [ hello ];

      #       unpackPhase = "true";

      #       buildPhase = ''
      #         echo 'running some integration tests'
      #         [[ $(hello) = 'Hello, world!' ]]
      #       '';

      #       installPhase = "mkdir -p $out";
      #     };

      #   # A VM test of the NixOS module.
      #   vmTest =
      #     with import (nixpkgs + "/nixos/lib/testing-python.nix")
      #       {
      #         inherit system;
      #       };

      #     makeTest {
      #       nodes = {
      #         client = { ... }: {
      #           imports = [ self.nixosModules.hello ];
      #         };
      #       };

      #       testScript =
      #         ''
      #           start_all()
      #           client.wait_for_unit("multi-user.target")
      #           client.succeed("hello")
      #         '';
      #     };
      # });

    };
}
