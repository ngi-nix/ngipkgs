{#Contributor_How_to_secure_a_service_with_systemd_analyze_security}
# How to secure a service with `systemd_analyze security`?

`systemd` supports [many options and mechanisms for hardening](https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#Sandboxing) service units,
mostly based upon Linux's `namespaces` and `seccomp`.

A system service can enable more sandboxing than a user service.

Resources:
- <https://www.synacktiv.com/publications/systemd-hardening-made-easy-with-shh>
