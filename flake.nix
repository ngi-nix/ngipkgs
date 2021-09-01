{
  description = "(insert short project description here)";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";

  # Upstream source tree(s).
  inputs = {

    npmlock2nix-src = { url = "github:nix-community/npmlock2nix"; flake = false; };

    # package sources
    dweb-search-frontend-src = { url = "github:ipfs-search/dweb-search-frontend"; flake = false; };
    ipfs-search-api-src = { url = "github:ipfs-search/ipfs-search-api"; flake = false; };
    ipfs-search-backend-src = { url = "github:ipfs-search/ipfs-search"; flake = false; };
    ipfs-sniffer-src = { url = "github:ipfs-search/ipfs-sniffer"; flake = false; };
    jaeger-src = { url = "github:jaegertracing/jaeger?ref=v1.25.0"; flake = false; };
  };

  outputs =
    { self
    , nixpkgs
    , # sources
      npmlock2nix-src
    , dweb-search-frontend-src
    , ipfs-search-api-src
    , ipfs-search-backend-src
    , ipfs-sniffer-src
    , jaeger-src
    }:
    let
      # Generate a user-friendly version numer.
      userFriendlyVersion = src: builtins.substring 0 8 src.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay npmlock2nixOverlay ]; });

      npmlock2nixOverlay = final: prev: {
        npmlock2nix = import npmlock2nix-src { pkgs = prev; };
      };

    in

    {

      # A Nixpkgs overlay.
      overlay = final: prev:
        let
          pkgs = final;
          # info = final.lib.splitString "-" final.stdenv.hostPlatform.system;
          # arch = final.lib.elemAt info 0;
          # plat = final.lib.elemAt info 1;
          # elkVersion = "7.8.1";
        in
        {

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

          ipfs-sniffer = pkgs.buildGoModule rec {
            pname = "ipfs-sniffer";
            version = "master";
            src = ipfs-sniffer-src;
            vendorSha256 = "sha256-xc1biJF4zicosSTFuUv82yvOYpbuY3h++rhvD+5aWNE=";
          };

          jaeger = pkgs.buildGoModule rec {
            pname = "jaeger";
            version = "v1.25.0";
            src = jaeger-src;
            vendorSha256 = "sha256-f/DIAw8XWb1osfXAJ/ZKsB0sOmFnJincAQlfVHqElBE=";
          };

          # Apache Tika server 
          tika-server = with final; stdenv.mkDerivation rec {
            name = "tika-server-1.26";
  
            src = fetchurl {
              url = https://archive.apache.org/dist/tika/tika-server-1.26.jar;
              sha256 ="sha256-GLXsW4p/gKPOJTz5PF6l8DGjwXvIPoirDSmlFujnPZU=";
            };
  
            dontUnpack = true;
            buildInputs =with nixpkgs; [
              jdk
              tesseract
              gdal
              gnupg
            ];
            nativeBuildInputs = [
              makeWrapper
            ];
            installPhase = ''
            echo "Installing.. "
              mkdir -pv $out/share/java $out/bin
              ls -l ${src}
            cp ${src} $out/share/java/tika-server-1.27.jar
            makeWrapper ${jre}/bin/java $out/bin/tika-server \
              --add-flags "-jar $out/share/java/tika-server-1.27.jar" \
              --set _JAVA_OPTIONS '-Dawt.useSystemAAFontSettings=on' \
              --set _JAVA_AWT_WM_NONREPARENTING 1
              '';
            meta = {
              homepage = "https://tika.apache.org/";
              description = ''
                The Apache Tika toolkit detects and extracts metadata and text from over a thousand different file types 
                (such as PPT, XLS, and PDF)
                '';
              };
            };
   
          # kibana7-oss = prev.kibana7-oss.overrideAttrs (old: {
          #   version = elkVersion;
          #   src = pkgs.fetchurl {
          #     url = "https://artifacts.elastic.co/downloads/kibana/kibana-oss-${elkVersion}-${plat}-${arch}.tar.gz";
          #     # TODO fix the sha for other platforms
          #     sha256 = "sha256-WWoOslKYWfoPc4wOU84QdxJln88JOmG8VhMaMtLraxs=";
          #   };
          # });

          # elasticsearch7-oss = prev.elasticsearch7-oss.overrideAttrs (old: {
          #   version = elkVersion;
          #   src = pkgs.fetchurl {
          #     url = "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${elkVersion}-${plat}-${arch}.tar.gz";
          #     # TODO fix the sha for other platforms
          #     sha256 = "sha256-eJ7tt6daRd5EdWMQMYy8BBPnArsjB5t03fjqScKivcU=";
          #   };
          # });

          # using nodejs 14 despite upstream uses version 10 (EOL)
          ipfs-search-api-server = pkgs.npmlock2nix.build {
            src = "${ipfs-search-api-src}/server";
            dontBuild = true;
            installPhase = ''
              mkdir -p $out/{bin,lib}

              # copy npmlock2nix modules to lib
              cp -r node_modules $out/lib/node_modules

              # copy source files to lib
              cp -r search $out/lib/search
              cp -r metadata $out/lib/metadata
              for file in esclient.js server.js types.js; do
                echo "#!$(${pkgs.which}/bin/which node)" > $out/lib/$file
                cat $file >> $out/lib/$file
              done

              chmod +x $out/lib/server.js

              ln -s $out/lib/server.js $out/bin/server
            '';
          };
        };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system})
            ipfs-search-backend
            dweb-search-frontend
            ipfs-sniffer
            jaeger
            kibana7-oss
            elasticsearch7-oss
            ipfs-search-api-server
            tika-server
            ;
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
            options.services.tika-server = {
                  enable = mkOption {
                    type = types.bool;
                    default = false;
                    description = ''
                    tika server
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
          
          #TODO need to put the requirement that all other required servives should be started first?

           config.services.tika-server = mkIf config.services.tika-server.enable {
              systemd.services.tika-server = {
                description = "Tika Server";
                   serviceConfig = {
                   ExecStart =  "${self.packages.x86_64-linux.tika-server}/bin/tika-server";
                      
                 };
               };
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
  };
}
