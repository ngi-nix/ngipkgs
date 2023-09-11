{
  configurations,
  modules,
  ...
}: {
  pretalx = import ./pretalx {
    configurations.server = {...}: {
      imports = [
        modules.pretalx
        modules.sops-nix
        configurations.pretalx-postgresql
      ];
    };
  };

  rosenpass = import ./rosenpass {
    configurations.common = {...}: {
      imports = [
        modules.rosenpass
        modules.sops-nix
      ];
    };
  };
}
