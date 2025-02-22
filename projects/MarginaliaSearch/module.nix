{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.marginalia-search;
  cfgOptionName = name: "services.marginalia-search.${name}";

  wrappedPkg = pkgs.symlinkJoin {
    name = "${pkgs.marginalia-search.pname}-configured-${pkgs.marginalia-search.version}";

    paths = [pkgs.marginalia-search];

    nativeBuildInputs = [pkgs.makeWrapper];

    postBuild = ''
      # Point it at new location
      rm $out/bin/${pkgs.marginalia-search.meta.mainProgram}
      makeWrapper ${lib.getExe pkgs.marginalia-search} $out/bin/${pkgs.marginalia-search.meta.mainProgram} \
        --set-default WMSA_HOME $out/share/marginalia

      # Add supplied configs
      rm \
        $out/share/marginalia/conf/properties/system.properties \
        $out/share/marginalia/conf/db.properties \

      ln -s ${(pkgs.formats.javaProperties {}).generate "system.properties" cfg.systemProperties} $out/share/marginalia/conf/properties/system.properties
      ln -s ${cfg.dbPropertiesFile} $out/share/marginalia/conf/db.properties
    '';

    # Externally defined symlinks may not exist at build time (i.e. populated by secrets manager)
    dontCheckForBrokenSymlinks = true;

    inherit (pkgs.marginalia-search) meta;
  };
in {
  options.services.marginalia-search = {
    enable = lib.mkEnableOption ''
      Marginalia Search, a search engine for a more human, non-commercial internet
    '';

    systemProperties = lib.mkOption {
      type = lib.types.attrs;
      description = "Settings that belong in <ROOT>/conf/properties/system.properties";
      default = {
        crawler.userAgentString = "Mozilla/5.0 (compatible)";
        crawler.userAgentIdentifier = "GoogleBot";
        crawler.poolSize = 256;

        log4j2.configurationFile = "log4j2-test.xml";

        search.websiteUrl = "http://localhost:8080";

        executor.uploadDir = "/uploads";
        converter.sideloadThreshold = 10000;

        ip-blocklist.disabled = false;
        blacklist.disable = false;
        flyway.disable = false;
        control.hideMarginaliaApp = false;

        zookeeper-hosts = "localhost:2181";

        #storage.root = "${pkgs.marginalia-search}/share/marginalia/index-1";
        storage.root = "/var/lib/marginalia-search/index-1";
      };
    };

    dbPropertiesFile = lib.mkOption {
      type = lib.types.string;
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

    environment.systemPackages = [wrappedPkg];
  };

  meta.maintainers = [];
}
