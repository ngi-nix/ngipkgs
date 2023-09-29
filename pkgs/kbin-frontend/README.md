
Get lockfile for vendor local files in kbin-core repo
``` bash
nix run nixpkgs#php82Packages.composer -- install --ignore-platform-req=ext-amqp --ignore-platform-req=ext-redis
```
