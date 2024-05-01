# Cachix Setup

## Read Access

Get the configuration from [cachix.nix](./cachix.nix).

## Write Access

[Install the `cachix` command line interface.][cachix-install]
Contact Lorenz Leutgeb and ask for write access to Cachix.
You'll receive an access token that you can use to [authenticate][cachix-auth].

The recommended method for pushing (=writin to the cache) is to use [`cachix watch-store`][cachix-watch-store].
This command will push all store paths that you build while it is running to our binary cache.
When you run this command, make sure that it will be terminated after a predefined duration.
The simple reason is that people tend to forget that they have the process running, and build things unrelated to NGIpkgs that then pollute our cache.
Be careful not to build anything unrelated to NGIpkgs while `cachix watch-store` is running, also because anything that ends up in there will be publicly available.
Your secrets should not end up in there.

### Using a Shell

This method is easy to set up and works well if you're using a terminal multiplexer anyway.

Before you start working on NGIpkgs, open a new shell, and run:
```
$ timeout 1h cachix watch-store ngi
```

### Using [home-manager]

Configure as follows:
```nix
{ pkgs, osConfig, ... }: {
  systemd.user.services."cachix-watch-store@ngi" = {
    Unit = {
      Description = "Cachix watching the store, pushing to ngi.cachix.org";
      After = ["network-online.target"];
    };
    Service = {
      Environment = "PATH=${osConfig.nix.package}/bin";
      ExecStart = "${pkgs.cachix}/bin/cachix watch-store ngi";
      RuntimeMaxSec = "1h";
    };
  };
}
```

Then, when you start working, run:
```
$ systemctl --user start cachix-watch-store@ngi
```

[home-manager]: https://nix-community.github.io/home-manager/
[cachix-install]: https://docs.cachix.org/installation
[cachix-auth]: https://docs.cachix.org/getting-started#authenticating
[cachix-watch-store]: https://docs.cachix.org/pushing#pushing-all-newly-built-store-paths
