# How to configure directories for systemd service

systemd provides several directory options for managing service data. These directories are automatically created with appropriate permissions and ownership.

## Directory types

- **StateDirectory** - Persistent data that survives across reboots (usually `/var/lib/<service>`)
- **CacheDirectory** - Temporary cached data (usually `/var/cache/<service>`)
- **RuntimeDirectory** - Runtime data cleared on reboot (usually `/run/<service>`)
- **LogsDirectory** - Log files (usually `/var/log/<service>`)

## Example

```nix
systemd.services.myservice = {
  serviceConfig = {
    # Note: use dynamic user if possible instead
    User = cfg.user;
    Group = cfg.group;

    # Persistent state directory at /var/lib/myservice
    StateDirectory = "myservice";

    # Cache directory at /var/cache/myservice
    CacheDirectory = "myservice";

    # Runtime directory at /run/myservice
    RuntimeDirectory = "myservice";

    # Access directories using %S (state), %C (cache), %t (runtime) specifiers
    ExecStart = "${lib.getExe cfg.package} --data-dir %S/myservice --cache-dir %C/myservice";
  };
};
```

## Custom directory paths

In case a custom state directory is needed, use `BindPaths` to bind mount directories:

```nix
systemd.services.myservice = {
  serviceConfig = {
    BindPaths = [
      "/custom/path:/var/lib/myservice"
    ];
  };
};
```

## Links

- [systemd directory options](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#RuntimeDirectory=)
- [BindPaths documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#BindPaths=)
