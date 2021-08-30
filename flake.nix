{
  description = "(insert short project description here)";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  # Upstream source tree(s).
  inputs.ipfs-search-backend-src = { url = "github:ipfs-search/ipfs-search"; flake = false; };
  inputs.dweb-search-frontend-src = { url = "github:ipfs-search/dweb-search-frontend"; flake = false; };

  outputs = { self, nixpkgs, ipfs-search-backend-src, dweb-search-frontend-src }:
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

        dweb-search-frontend = with final; mkYarnPackage rec {
          pname = "dweb-search-frontend";
          version = userFriendlyVersion src;
          src = dweb-search-frontend-src;
          yarnNix = ./yarn.nix;
          yarnLock = ./yarn.lock;
          installPhase = ''
            yarn --offline build
            cp -r deps/dweb-search-frontend/dist $out
          '';
          # don't generate the dist tarball
          # (`doDist = false` does not work in mkYarnPackage)
          distPhase = ''
            true
          '';
        };

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) ipfs-search-backend dweb-search-frontend;
        });


      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.ipfs-search =
        { pkgs, config, lib, ... }:
          with lib;
          {
            config.nixpkgs.overlays = [ self.overlay ];

            config.environment.systemPackages = with pkgs;[ ipfs-search-backend dweb-search-frontend ];

            options.services.ipfs-search = {
              enable = mkOption {
                type = types.bool;
                default = false;
                description = ''
                  Whether to enable the ipfs-search service. It uses Rabbitmq, elastic-search, ipfs
                '';
              };

            };
            config.services.rabbitmq = mkIf config.services.ipfs-search.enable {
              enable = true;
              managementPlugin.enable = true;
            };
            config.services.elasticsearch = mkIf config.services.ipfs-search.enable {
              enable = true;
              package = pkgs.elasticsearch7-oss;
            };
            config.services.kibana = mkIf config.services.ipfs-search.enable {
              enable = true;
              package = pkgs.kibana7-oss;
            };
            config.services.ipfs.enable = config.services.ipfs-search.enable;
            # https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size 
            # 2021/08/27 02:08:25 failed to sufficiently increase receive buffer size (was: 208 kiB, wanted: 2048 got: 416 kiB). See https://github.com/lucas-clemente/quic-go/wiki/UDP-Receive-Buffer-Size for details
            config.boot.kernel.sysctl."net.core.rmem_max" = mkDefault 2500000;
            #systemd.services = { ... };
          };

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
