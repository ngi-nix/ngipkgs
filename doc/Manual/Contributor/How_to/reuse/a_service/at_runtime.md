# How to reuse a service at runtime {#Contributor_How_to_reuse_a_service_at_runtime}

As `root` user create a `/run/systemd/system/${service}.service.d/override.conf` with:
```bash
$ systemctl edit --runtime ${service}.service
[edit-file]
$ systemctl daemon-reload
```

Check the result with:
```
systemctl cat ${service}.service
```

Beware that in the `override.conf` you may need to delete previous settings
with an empty entry:
```
[Service]
ExecStart=
ExecStart=/run/current-system/sw/bin/tor -f /etc/torrc
```

Don't forget to remove `/run/systemd/system/${service}.service.d/override.conf`
once you're done with your edit and want to configure the service with only NixOS again.
