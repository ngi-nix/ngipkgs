# Pretalx Service

This provides [pretalx][pretalx].

## Production Deployment

The configuration at `/configs/pretalx/pretalx.nix` and `/config/pretalx/{mysql,postgresql}.nix` serves as a starting point for a production-ready configuration to deploy pretalx.

### Secret Management

It is recommended to use a secret management scheme for security (see [this comparison][secret-management-comparison]).
In the example configuration in `/configs/pretalx/pretalx.nix`, we use [sops-nix][sops-nix] with [age][age] for the options `services.pretalx.*.*File`.

### TLS Certificates for HTTPS

In order to enable HTTPS, you can obtain the TLS certificates via ACME. See the [NixOS manual][nixos-manual-acme] for details.

## Packaging

### Plugins

See [`pyproject.toml`](./pyproject.toml) for the list of included plugins.

Note that the plugin `prtx-faq` is broken as of 2023-08-24 and therefore not included in the package definition.

### Pretalx Version Update

* Update the version of `pretalx` in `tool.poetry.dependencies` section of `/pkgs/pretalx/pyproject.toml` file.
* Run `nix run nixpkgs#poetry -- lock` in `/pkgs/pretalx`. This will update `/pkgs/pretalx/poetry.lock`.
* Build the package via `nix build .#pretalx`. If this fails, refer to `poetry2nix` documentation, e.g. to [Edge cases][poetry2nix-edge] if the error is "missing `setuptools`" or similar, and manually apply overrides to repair dependencies. Check `/pkgs/pretalx/default.nix` for examples.

### Testing

Run NixOS integration tests using
```sh
nix build -L .#nixosTests.x86_64-linux.pretalx
```

#### Interactive Tests

Run NixOS integration tests interactively using
```sh
nix build -L .#nixosTests.x86_64-linux.pretalx.driverInteractive
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

