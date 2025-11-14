{#Contributor_How_to_reuse_a_service_at_runtime}
# How to reuse a service at runtime?

For a `systemd` system service named `${service}`, use:
```bash
$ systemctl edit --runtime ${service}.service
[edit-file]
$ systemctl daemon-reload
```
This creates a file in
`/run/systemd/system/${service}.service.d/override.conf`
that will not persist accross a reboot.

If you want to append to a setting, but instead of replace it,
begin with an empty entry:
```
[Service]
ExecStart=
ExecStart=/run/current-system/sw/bin/tor -f /etc/torrc
```

Check the aggregated result with:
```
systemctl cat ${service}.service
```

:::{warning}
Don't forget to remove `/run/systemd/system/${service}.service.d/override.conf`
once you're done with your edit and want to configure the service with only NixOS again.
:::
