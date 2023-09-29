{...}: {
  boot.isContainer = true;

  networking.useDHCP = false;
  networking.hostName = "liberaforms";

  # A timezone must be specified for use in the LiberaForms config file
  time.timeZone = "Etc/UTC";

  services.liberaforms = {
    enable = true;
    flaskEnv = "development";
    flaskConfig = "development";
    enablePostgres = true;
    enableNginx = true;
    #enableHTTPS = true;
    domain = "liberaforms.local";
    enableDatabaseBackup = true;
    rootEmail = "admin@example.org";
  };

  system.stateVersion = "22.11";

  nixpkgs.hostPlatform = "x86_64-linux";
}
