{
  liberaforms-container = import ./liberaforms/container.nix;
  pretalx-postgresql = {
    imports = [
      ./pretalx/pretalx.nix
      ./pretalx/postgresql.nix
    ];
  };
  pretalx-mysql = {
    imports = [
      ./pretalx/pretalx.nix
      ./pretalx/mysql.nix
    ];
  };
}
