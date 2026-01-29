{#Contributor_How_to_maintain_security_of_a_service_with_systemd-analyze_security}
# How to maintain security of a service with `systemd-analyze`?

[`systemd-analyze security`](#Contributor_What_is_security_tool_systemd-analyze_security) has a `--threshold=` parameter that can be used
to check the hardening level according to systemd's pondering.

For example, using `--threshold=10` to check the level of `${service}` is `<= 1.0`:
```python
testScript =
  { nodes, ... }@args:
  ''
    print(seed.succeed("systemd-analyze security ${service}.service --threshold=10 --no-pager"))
  ''
```
