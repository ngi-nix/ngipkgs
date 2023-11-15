# Overview

ipfs-search is a search engine for the [ipfs](https://ipfs.io/) file system.

The search engine itself is composed of
- a crawler, to crawl file contents.
- a sniffer to sniff DHT gossip, index files and directory hashes.
- metadata and content extraction is done with ipfs-tika
- search is done with elasticsearch 7
- the frontend to make queries is built in javascript (dweb)
- queuing is done with AMQP (rabbitmq)

additionally this service deploys a [jaeger](https://www.jaegertracing.io/) service for tracing.

## Quickstart

after adding the flake module to your installation, you will have an ipfs-search option in services.
(simply adding `ipfs-search-src.nixosModules.ipfs-search` to your modules)

to start `services.ipfs-search.enable = true;`

## Notes

- the frontend for the search engine is in a state of transition and not finished. This flake builds it but doesn't deploy it. The main reason being that the frontend is not connected to this custom backend at this moment.

- This service deploys an ipfs setup that doesn't listen on private networks. Listening on private networks can enable data sharing with other nodes, however it is not accepted by most server providers.

- By default this exposes a rabbitmq management plugin on port `15672`. Exposing that through your reverse proxy can facilitate monitoring of rabbitmq.
  With caddy for example this would be
```
{
  services.caddy.virtualHosts."rabbitmq-management.mydomain.com" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.rabbitmq.managementPlugin.port}
    '';
  };
}
```

- By default the ipfs-search service deploys a kibana service to facilitate management of elasticsearch. Exposing of the kibana service through a reverse proxy can be done in the following way (with caddy)
```
{
  services.caddy.virtualHosts."kibana.mydomain.com" = {
    extraConfig = ''
      reverse_proxy 127.0.0.1:${toString config.services.kibana.port}
    '';
  };
}
```
- At this moment the only way to verify that the service is working correctly is to check the systemctl logs for each service. Using something like grafana loki can make it convenient to browse the logs. Otherwise a simple `journalctl --unit ipfs-crawler` for example.
