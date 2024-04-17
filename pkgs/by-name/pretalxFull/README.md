# Pretalx Service

This provides [pretalx][pretalx] as `services.ngi-pretalx`.

## Production Deployment

The configurations in `/projects/Pretalx/config/` serve as a starting point for a production-ready configuration to deploy pretalx.

### Secret Management

It is recommended to use a secret management scheme for security (see [this comparison][secret-management-comparison]).
In the example configuration at `/projects/Pretalx/config/base.nix`, we use [sops-nix][sops-nix] with [age][age] for the options `services.ngi-pretalx.*.*File`.

### TLS Certificates for HTTPS

In order to enable HTTPS, you can obtain the TLS certificates via ACME. See the [NixOS manual][nixos-manual-acme] for details.

## Packaging

### Plugins

See [`pretalxPlugins`](../pretalxPlugins/package.nix) for the list of included plugins.

Note that the plugins `pretalxPlugins.pretalx-{vimeo,youtube}` are broken as of 2024-04-17 and therefore not included in the package definition.

### Testing

Run NixOS integration tests using

```sh
nix build -L .#pretalxFull.passthru.tests.pretalx
```

#### Interactive Tests

Run NixOS integration tests interactively using

```sh
nix build -L .#pretalxFull.passthru.tests.pretalx.driverInteractive
./result/bin/nixos-test-driver # Start a shell
```

Once in the spawned shell, you can start a VM that will execute the tests using the following command:

```python
start_all() # Run the VM
```

If you want to use your browser to connect to the `pretalx` server at <http://localhost:8000/orga/admin>, you may set up port forwarding as follows:

```python
server.forward_port(host_port=8000, guest_port=80)
```

[pretalx]: https://github.com/pretalx/pretalx
[poetry2nix-edge]: https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md
[secret-management-comparison]: https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes
[sops-nix]: https://github.com/Mic92/sops-nix
[age]: https://github.com/FiloSottile/age
[nixos-manual-acme]: https://nixos.org/manual/nixos/stable/#module-security-acme-nginx

