{
  pkgs,
  config,
  lib,
  ...
}:
with lib; {
  options.services.ipfs-search = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable the ipfs-search service. It uses Rabbitmq, elastic-search, ipfs
      '';
    };
  };

  config.environment.systemPackages = with pkgs; [
    ipfs-crawler
    dweb-search-frontend
    ipfs-sniffer
    jaeger
    ipfs-search-api-server
    tika-extractor
  ];

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

  config.systemd = mkIf config.services.ipfs-search.enable {
    services.tika-extractor = {
      description = "Tika extractor";
      after = ["ipfs.service"];
      wants = ["ipfs.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.tika-extractor}/bin/tika-extractor";
        DynamicUser = true;
      };
    };

    services.ipfs-crawler = {
      description = "The ipfs crawler";
      after = ["ipfs.service" "elasticsearch.service" "tika-extractor.service" "rabbitmq.service" "jaeger.service"];
      wants = ["ipfs.service" "elasticsearch.service" "tika-extractor.service" "rabbitmq.service" "jaeger.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.ipfs-crawler}/bin/ipfs-search crawl";
        DynamicUser = true;
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

    services.ipfs-sniffer = {
      description = "IPFS sniffer";
      after = ["rabbitmq.service" "jaeger.service"];
      wants = ["rabbitmq.service" "jaeger.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.ipfs-sniffer}/bin/hydra-booster -db '/var/lib/ipfs-sniffer'";
        StateDirectory = "ipfs-sniffer";
        DynamicUser = true;
      };
      environment = {
        AMQP_URL = "amqp://guest:guest@localhost:5672/";
        OTEL_EXPORTER_JAEGER_ENDPOINT = "http://localhost:14268/api/traces";
      };
    };

    services.ipfs-search-api-server = {
      description = "IPFS search api";
      after = ["elasticsearch.service"];
      wants = ["elasticsearch.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.ipfs-search-api-server}/bin/server";
        DynamicUser = true;
      };
      environment = {
        ELASTICSEARCH_URL = "http://elasticsearch:9200";
      };
    };

    services.jaeger = {
      description = "jaeger tracing";
      after = ["elasticsearch.service"];
      wants = ["elasticsearch.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.jaeger}/bin/all-in-one";
        DynamicUser = true;
      };
      environment = {
        SPAN_STORAGE_TYPE = "elasticsearch";
        ES_SERVER_URLS = "http://localhost:9200";
        ES_TAGS_AS_FIELDS_ALL = "true";
      };
    };
  };
}
