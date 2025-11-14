# How to install a service {#User_How_to_install_a_service}

Any `services.${service}.enable` option,
(where `${service}` is to be replaced with the name of a service (eg. `bonfire`))
enables a working instance of the
service in at least a minimal usable configuration.

If other services are required for `${service}` to work properly,
they are automatically enabled as well.

Convenient opt-in options may be available as well
to enable integrations into other services.
For example, `services.${service}.nginx.enable`
may be available to setup an Nginx reverse proxy.

<!-- ToDo: refer to a section of the manual listing all available options. -->
