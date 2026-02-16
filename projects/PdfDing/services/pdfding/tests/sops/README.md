## Example sops file

```yaml
pdfding:
  django:
    secret_key: 2025-extra-contributors
  s3:
    user: GK0a0a0a0b0b0b0c0c0c0d0d0d
    password: 0a0a0a0a0b0b0b0b0c0c0c0c0d0d0d0d1a1a1a1a1b1b1b1b1c1c1c1c1d1d1d1d
```

Can be edited via

`nix-shell -p sops --run "SOPS_AGE_KEY_FILE=./keys.txt sops pdfding.yaml"`
