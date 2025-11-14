# How to scale a service with a splice {#Contributor_How_to_scale_a_service_with_a_splice}

[`Slice=`](https://www.man7.org/linux/man-pages/man5/systemd.slice.5.html)
enables to group processes for common accounting, easier stopping,
out-of-memory management, concurrency management …

```nix
{
  systemd.slices.system-hydra = {
    description = "Hydra CI Server Slice";
    documentation = [
      "file://${cfg.package}/share/doc/hydra/index.html"
      "https://nixos.org/hydra/manual/"
    ];
  };

  systemd.services.hydra-init = {
    serviceConfig = {
      Slice = "system-hydra.slice";
      …
    };
  };

  systemd.services.hydra-server = {
    serviceConfig = {
      Slice = "system-hydra.slice";
      …
    };
  };

  systemd.services.hydra-queue-runner = {
    serviceConfig = {
      Slice = "system-hydra.slice";
      …
    };
  };
}
```
