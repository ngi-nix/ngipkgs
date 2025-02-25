{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.marginalia-search;
  cfgOptionName = name: "services.marginalia-search.${name}";

  wrappedPkg = pkgs.symlinkJoin {
    name = "${pkgs.marginalia-search.pname}-configured-${pkgs.marginalia-search.version}";

    paths = [ pkgs.marginalia-search ];

    nativeBuildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      # Point it at new location
      rm $out/bin/${pkgs.marginalia-search.meta.mainProgram}
      makeWrapper ${lib.getExe pkgs.marginalia-search} $out/bin/${pkgs.marginalia-search.meta.mainProgram} \
        --set-default WMSA_HOME $out/share/marginalia \
        --set-default WMSA_DATA /var/lib/marginalia-search/data

      # Add supplied configs
      rm \
        $out/share/marginalia/conf/properties/system.properties \
        $out/share/marginalia/conf/db.properties \

      ln -s ${
        (pkgs.formats.javaProperties { }).generate "system.properties" cfg.systemProperties
      } $out/share/marginalia/conf/properties/system.properties
      ln -s ${cfg.dbPropertiesFile} $out/share/marginalia/conf/db.properties
    '';

    # Externally defined symlinks may not exist at build time (i.e. populated by secrets manager)
    dontCheckForBrokenSymlinks = true;

    inherit (pkgs.marginalia-search) meta;
  };
in
{
  options.services.marginalia-search = {
    enable = lib.mkEnableOption ''
      Marginalia Search, a search engine for a more human, non-commercial internet
    '';

    systemProperties = lib.mkOption {
      type = lib.types.attrs;
      description = "Settings that belong in <ROOT>/conf/properties/system.properties";
      default = {
        "crawler.userAgentString" = "Mozilla/5.0 (compatible)";
        "crawler.userAgentIdentifier" = "GoogleBot";
        "crawler.poolSize" = "256";

        "log4j2.configurationFile" = "log4j2-test.xml";

        "search.websiteUrl" = "http://localhost:8080";

        "executor.uploadDir" = "/uploads";
        "converter.sideloadThreshold" = "10000";

        "ip-blocklist.disabled" = "false";
        "blacklist.disable" = "false";
        "flyway.disable" = "false";
        "control.hideMarginaliaApp" = "false";

        "zookeeper-hosts" = "localhost:2181";

        "storage.root" = "/var/lib/marginalia-search/index-1";
      };
    };

    dbPropertiesFile = lib.mkOption {
      type = lib.types.str;
      description = ''
        Path at runtime to a Java .properties file with sensitive settings for <ROOT>/conf/db.properties.

        For an example, look at run/install/db.properties.template in marginalia-search's src.
      '';
      default = "";
    };
  };

  config = lib.mkIf (cfg.enable) {
    assertions = [
      {
        assertion = lib.strings.stringLength cfg.dbPropertiesFile > 0;
        message = "${cfgOptionName "dbPropertiesFile"} must not be empty (and point at a valid file, but we can't check that)";
      }
    ];

    environment.systemPackages = [ wrappedPkg ];

    users.users.marginalia-search = {
      group = "marginalia-search";
      home = "/var/lib/marginalia-search";
      createHome = true;
      isNormalUser = true;
    };

    users.groups.marginalia-search = { };

    systemd.services = {
      "marginalia-search" = rec {
        description = "Marginalia Search";
        wants = [
          "mysql.service"
          "zookeeper.service"
        ];
        after = wants;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "exec";
          User = "marginalia-search";
          ExecStart = "${lib.getExe (
            pkgs.writeShellApplication {
              name = "run-marginalia";
              text = ''
                if [ ! -d "$HOME/data" ]; then
                  mkdir -p "$HOME/data"
                fi

                ${lib.getExe wrappedPkg} control:1 127.0.0.1:7000:7001 127.0.0.2
              '';
            }
          )}";
        };
      };
    };
  };

  meta.maintainers = [ ];
}
