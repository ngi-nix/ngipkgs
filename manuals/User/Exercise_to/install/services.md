{#User_Exercise_to_install_services}
# Exercise to install `services`

To enable a service `${service}`, setting in your configuration:
```nix
services.${service}.enable = true;
```
should be enough,
unless some credentials are required,
in which case those must be set too.

```{toctree}
services/bonfire.md
```
