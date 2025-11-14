{#Contributor_How_to_secure_a_service_with_systemd-confinement}
# How to secure a service with `systemd_confinement`?

```nix
service.${service} = {
  confinement = {
    enable = true;
    mode = "full-apivfs";
    packages = [
      cfg.package
      pkgs.iana-etc
      (lib.getLib pkgs.nss)
      pkgs.tzdata
    ];
  };
};
```

Note: `full-apivfs` is usually necessary.

Warning: the list of `packages` may vary.
