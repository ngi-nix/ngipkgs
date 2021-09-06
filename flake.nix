{
  description = "(insert short project description here)";

  inputs = {
    # Nixpkgs / NixOS version to use.
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    npmlock2nix-src = { url = "github:nix-community/npmlock2nix"; flake = false; };

    # package sources
    dweb-search-frontend-src = { url = "github:ipfs-search/dweb-search-frontend"; flake = false; };
    ipfs-search-api-src = { url = "github:ipfs-search/ipfs-search-api"; flake = false; };
    ipfs-crawler-src = { url = "github:ipfs-search/ipfs-search"; flake = false; };
    ipfs-sniffer-src = { url = "github:ipfs-search/ipfs-sniffer"; flake = false; };
    jaeger-src = { url = "github:jaegertracing/jaeger?ref=v1.25.0"; flake = false; };
    mvn2nix.url = "github:fzakaria/mvn2nix";
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
    , mvn2nix
    }:
    let
      # Generate a user-friendly version numer.
      userFriendlyVersion = src: builtins.substring 0 8 src.lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Nixpkgs instantiated for supported system types.

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ mvn2nix.overlay self.overlay ]; });
    in
    {
      # A Nixpkgs overlay.
      overlay = final: prev:
        let
          npmlock2nix = import npmlock2nix-src { pkgs = final; };
          mavenRepository = final.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
        in
        {
          ipfs-crawler = final.buildGo115Module rec {
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

          dweb-search-frontend = final.mkYarnPackage rec {
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

          ipfs-sniffer = final.buildGoModule rec {
            pname = "ipfs-sniffer";
            version = "master";
            src = ipfs-sniffer-src;
            vendorSha256 = "sha256-xc1biJF4zicosSTFuUv82yvOYpbuY3h++rhvD+5aWNE=";
          };

          jaeger = final.buildGoModule rec {
            pname = "jaeger";
            version = "v1.25.0";
            src = jaeger-src;
            vendorSha256 = "sha256-f/DIAw8XWb1osfXAJ/ZKsB0sOmFnJincAQlfVHqElBE=";
          };


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
                echo "#!$(${which}/bin/which node)" > $out/lib/$file
                cat $file >> $out/lib/$file
              done

              chmod +x $out/lib/server.js

              ln -s $out/lib/server.js $out/bin/server
            '';
          };

          tika-extractor = final.stdenv.mkDerivation rec {
            pname = "tika-extractor";
            version = "1.1";
            src = fetchGit {
              url = https://github.com/ipfs-search/tika-extractor;
              ref = "main";
              rev = "e629c4a6362916001deb430584ddc3fdc8a4bf6a";
            };

            nativeBuildInputs = with final;[ jdk11_headless maven makeWrapper ];
            buildPhase = ''
              echo "Building with maven repository ${mavenRepository}"
              mvn package --offline -Dmaven.repo.local=${mavenRepository} -Dquarkus.package.type=uber-jar
            '';

            installPhase = ''
              mkdir -p $out/bin
              ln -s ${mavenRepository} $out/lib
              ls -l
              cp target/${pname}-${version}-runner.jar $out/
              makeWrapper ${jdk11_headless}/bin/java $out/bin/${pname} \
                    --add-flags "-jar $out/${pname}-${version}-runner.jar"
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
            tika-extractor;
        });


      # A NixOS module, if applicable (e.g. if the package provides a system service).
      nixosModules.ipfs-search =
        { pkgs, config, lib, ... }:
          with lib;
          {
            config.nixpkgs.overlays = [ mvn2nix.overlay self.overlay ];

            config.environment.systemPackages = with pkgs;[
              ipfs-crawler
              dweb-search-frontend
              ipfs-sniffer
              jaeger
              ipfs-search-api-server
              tika-extractor
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

            config.systemd.services.tika-extractor = mkIf config.services.ipfs-search.enable {
              description = "Tika extractor";
              serviceConfig = {
                ExecStart = "${pkgs.tika-extractor}/bin/tika-extractor";
              };
            };


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
              after = [ "rabbitmq.service" "jaeger.service" ];
              wants = [ "rabbitmq.service" "jaeger.service" ];
              environment = {
                AMQP_URL = "amqp://guest:guest@localhost:5672/";
                OTEL_EXPORTER_JAEGER_ENDPOINT = "http://localhost:14268/api/traces";
              };
            };

            config.systemd.services.ipfs-search-api-server = mkIf config.services.ipfs-search.enable {
              description = "IPFS search api";
              after = [ "elasticsearch.service" ];
              wants = [ "elasticsearch.service" ];
              serviceConfig = {
                ExecStart = "${pkgs.ipfs-search-api-server}/bin/server";
              };
              environment = {
                ELASTICSEARCH_URL = "http://elasticsearch:9200";
              };
            };

            config.systemd.services.jaeger = mkIf config.services.ipfs-search.enable {
              description = "jaeger tracing";
              after = [ "elasticsearch.service" ];
              wants = [ "elasticsearch.service" ];
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
