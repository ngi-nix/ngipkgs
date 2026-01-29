{#Contributor_Why_to_secure_a_service_with_systemd_confinement}
# Why to secure a service with `systemd_confinement`?

[`systemd-confinemenŧ`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/systemd-confinement.nix)
is specific to NixOS,
it leverages `pkgs.closureInfo` to only bind necessary Nix store paths
within the `RootDirectory=` of the systemd service.

{#Contributor_Why_to_secure_a_service_with_systemd_confinement_Pros}
## Pros
- it increases [confidentiality](#Contributor_What_is_security_confidentiality).
- it mitigates [Living Off The Land](#Contributor_What_is_security_threat_Living_Of_The_Land) breaches.

{#Contributor_Why_to_secure_a_service_with_systemd_confinement_Cons}
## Cons
- very few packages in Nixpkgs enable it by default.
- it may require the end_user to add additional packages to `services.${service}.confinement.packages`.
