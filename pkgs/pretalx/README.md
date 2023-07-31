# Pretalx Service

This provides [pretalx][pretalx].

## Packaging

### Pretalx Version Update

* Update the version of `pretalx` in `tool.poetry.dependencies` section of `/pkgs/pretalx/pyproject.toml` file.
* Run `nix run nixpkgs#poetry -- lock` in `/pkgs/pretalx`. This will update `/pkgs/pretalx/poetry.lock`.
* Build the package via `nix build .#pretalx`. If this fails, refer to `poetry2nix` documentation, e.g. to [Edge cases][poetry2nix-edge] if the error is "missing `setuptools`" or similar, and manually apply overrides to repair dependencies. Check `/pkgs/pretalx/default.nix` for examples.

### Testing

Run NixOS integration tests using
```sh
nix build -L .#checks.x86_64-linux.test-pretalx
```

#### Interactive Tests

Run NixOS integration tests interactively using
```sh
nix build -L .#checks.x86_64-linux.test-pretalx.driverInteractive
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

## Deployment

[pretalx]: https://github.com/pretalx/pretalx
[poetry2nix-edge]: https://github.com/nix-community/poetry2nix/blob/master/docs/edgecases.md