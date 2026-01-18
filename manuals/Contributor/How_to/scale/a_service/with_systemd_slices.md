{#Contributor_How_to_scale_a_service_with_systemd_slices}
# How to scale a service with `systemd.slices`?

[`systemd.slices`](https://www.freedesktop.org/software/systemd/man/latest/systemd.slice.html)
enable to group several related
[`systemd.services`](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html)
in order to [control their resources](https://www.freedesktop.org/software/systemd/man/latest/systemd.resource-control.html)

Considering a software `foo` consisting of two related
`systemd.services.foo-1` and `systemd.services.foo-2`,
grouping them under a dedicated `systemd.splices.system-foo`
can be done like that:
```nix
{ pkgs, lib, config, ... }:
{
  systemd.slices.system-foo = {
    description = "Foo Slice";
    documentation = [ "https://foo.example.org" ];
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.foo-1 = {
    wantedBy = [ "system-foo.slice" ];
    partOf = [ "system-foo.slice" ];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.coreutils "sleep"} infinity";
      Slice = "system-foo.slice";
    };
  };
  systemd.services.foo-2 = {
    wantedBy = [ "system-foo.slice" ];
    partOf = [ "system-foo.slice" ];
    serviceConfig = {
      ExecStart = "${lib.getExe' pkgs.coreutils "sleep"} infinity";
      Slice = "system-foo.slice";
    };
  };
}
```
:::{warning}
Use the `system-` prefix to make the slice a child of `system.slice`
and the `user-${user.uid}-` to make the slice a child of `user-${user.uid}.slice`.
:::

:::{note}
If only starting and stopping is useful
a [systemd.targets](https://www.freedesktop.org/software/systemd/man/latest/systemd.target.html) can instead
be used, replacing `system-foo.slice` by `foo.target`.
:::
to enable users to start (resp. stop) them with `systemctl start foo.target`
(resp. `systemctl stop foo.target`).
