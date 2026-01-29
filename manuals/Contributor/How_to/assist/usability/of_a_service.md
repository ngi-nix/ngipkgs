{#Contributor_How_to_assist_usability_of_a_service}
# How to assist usability of a service?

As expected by [How to install a service](#User_How_to_install_a_service),
a service can provide convenient opt-in options
to configure its integration into other services (a database, a cache, a reverse-proxy, a mail-server, …)
to assist users not necessarily knowing how to configure those integrations.

Such convenient options usually cannot and should not handle all possible integrations,
just a sensible integration providing the user with an easy way
to configure services running on the same host.

When enabled, a sensible integration :
- configures its integration;
- enables the dependent service using `lib.mkDefault`;
- does not add `assertions` that the dependent services are enabled;
- assumes that the dependent service runs on the same host;
- when possible, integrates without claiming any unique shared resources
  (eg. uses a Unix socket in the runtime directory of the service
  instead of binding to a TCP or UDP port on the loopback interface).

Users fancying an alternative integration
could just not opt-in and instead configure their own integration.
Examples of those alternative integrations can be provided
as examples imported in both:
- the service's documentation,
- the service's `passthru.tests` and/or `nixosTests`.

<!--
ToDo: [NixOS RFC 189](https://github.com/ibizaman/rfcs/blob/contracts/rfcs/0189-contracts.md)
is a relevant draft aiming to assist usability of services.
-->

```{toctree}
of_a_service/using_Caddy.md
of_a_service/using_Nginx.md
of_a_service/using_Postfix.md
of_a_service/using_PostgreSQL.md
of_a_service/using_Redis.md
```
