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
    ipfs-crawler-src = { url = "github:ipfs-search/ipfs-search"; flake = false; };
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
    , ipfs-crawler-src
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
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
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
          npmlock2nix = import npmlock2nix-src { inherit pkgs; };
        in
        {

          ipfs-crawler = with final; buildGo115Module rec {
            pname = "ipfs-crawler";
            version = userFriendlyVersion src;

            vendorSha256 = "sha256-bz427bRS0E1xazQuSC7GqHSD5yBBrDv8o22TyVJ6fho=";
            src = ipfs-crawler-src;

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
            doCheck = false;
          };

          jaeger = pkgs.buildGoModule rec {
            pname = "jaeger";
            version = "v1.25.0";
            src = jaeger-src;
            vendorSha256 = "sha256-f/DIAw8XWb1osfXAJ/ZKsB0sOmFnJincAQlfVHqElBE=";
          };

          # Apache Tika server 
          tika-server = with final; stdenv.mkDerivation rec {
            pname = "tika-server";
            version = "1.26";
            src = fetchurl {
              url = "https://archive.apache.org/dist/tika/tika-server-${version}.jar";
              sha256 = "sha256-GLXsW4p/gKPOJTz5PF6l8DGjwXvIPoirDSmlFujnPZU=";
            };
            dontUnpack = true;
            buildInputs = with nixpkgs; [
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
              cp ${src} $out/share/java/tika-server-${version}.jar
              makeWrapper ${jre}/bin/java $out/bin/tika-server \
                --add-flags "-jar $out/share/java/tika-server-${version}.jar" \
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
          ipfs-search-api-server = npmlock2nix.build {
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
            ipfs-crawler
            dweb-search-frontend
            ipfs-sniffer
            jaeger
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

            config.environment.systemPackages = with pkgs;[
              ipfs-crawler
              dweb-search-frontend
              ipfs-sniffer
              jaeger
              ipfs-search-api-server
              tika-server
            ];

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

            config.systemd.services.ipfs-crawler = mkIf config.services.ipfs-search.enable {
              description = "The ipfs crawler";
              after = [ "ipfs.service" "elasticsearch.service" "tika-server.service" "rabbitmq.service" "jaeger.service" ];
              wants = [ "ipfs.service" "elasticsearch.service" "tika-server.service" "rabbitmq.service" "jaeger.service" ];
              serviceConfig = {
                ExecStart = "${pkgs.ipfs-crawler}/bin/ipfs-search crawl";
              };
              environment = {
                TIKA_EXTRACTOR = "http://localhost:8081";
                IPFS_API_URL = "http://localhost:5001";
                IPFS_GATEWAY_URL = "http://localhost:8080";
                ELASTICSEARCH_URL = "http://localhost:9200";
                AMQP_URL = "amqp://guest:guest@localhost:5672/";
                OTEL_EXPORTER_JAEGER_ENDPOINT = "http://localhost:14268/api/traces";
                OTEL_TRACE_SAMPLER_ARG = "1.0";
              };
            };

            config.systemd.services.ipfs-sniffer = mkIf config.services.ipfs-search.enable {
              description = "IPFS sniffer";
              serviceConfig = {
                ExecStart = "${pkgs.ipfs-sniffer}/bin/hydra-booster";
              };
              environment = {
                AMQP_URL = "amqp://guest:guest@localhost:5672/";
                OTEL_EXPORTER_JAEGER_ENDPOINT = "http://localhost:14268/api/traces";
              };
            };

            config.systemd.services.jaeger = mkIf config.services.ipfs-search.enable {
              description = "jaeger tracing";
              after = [ "network.target" ];
              wants = [ "network.target" ];
              serviceConfig = {
                ExecStart = "${pkgs.jaeger}/bin/all-in-one";
              };
              environment = {
                SPAN_STORAGE_TYPE = "elasticsearch";
                ES_SERVER_URLS = "http://localhost:9200";
                ES_TAGS_AS_FIELDS_ALL = "true";
              };
            };

            config.systemd.services.tika-server = mkIf config.services.ipfs-search.enable {
              description = "Tika Server";
              serviceConfig = {
                ExecStart = "${pkgs.tika-server}/bin/tika-server";
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
