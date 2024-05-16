{
  lib,
  nixosTest,
  anastasis,
  pkgs,
  ...
}:
nixosTest {
  name = "anastasis-httpd";
  nodes = {
    client = {...}: {
      systemd.services.anastasis-httpd = {
        wantedBy = ["multi-user.target"];
        serviceConfig.ExecStart = ''
          ${anastasis}/bin/anastasis-httpd
        '';
      };
      environment.systemPackages = with pkgs; [
        anastasis
        postgresql
        taler-exchange
        taler-merchant

        # needed by src/cli/test_*
        jq
        wget

        # needed by make check
        gnumake
        automake
        autoconf
        autoconf-archive
        autoconf-archive
        pkg-config
        libgcrypt.dev
        gcc
      ];

      services.postgresql = {
        enable = true;
        initialScript = pkgs.writeText "initialScript.sql" ''
          create role root login createdb;
        '';
      };
    };
  };
  testScript = let
    check-anastasis = pkgs.writeScript "check-anastasis" ''
      # Load test fixture data into the vm $HOME (/root)
      cd ${anastasis.configured} && find . -type f -exec install -Dm 755 "{}" "$HOME/{}" \;
      cd $HOME
      # Patch some paths
      sed=${pkgs.gnused}/bin/sed
      find . -type f -exec $sed -i "s^/build/source^$HOME^g" "{}" \;
      find . -type f -exec $sed -i "s^/usr/bin/file^${pkgs.file}/bin/file^g" "{}" \;

      # ./missing is executed at the beginning of `make check` and re-triggers autoreconf
      #   -> Fix that by making missing a no-op
      echo ":" > missing

      for i in "" $(seq 1 4); do createdb anastasischeck$i; done

      # Start checking anastasis
      # FIXME: recursvely adds paths to dependencies
      # Provide all the paths toward header files and libraries, as well as pkg-config files
      # This can be debugged by prefixing with "NIX_DEBUG=1 "
      # FIXME: the build is triggered !!! making the check *very* long :(
      #  a solution would be to copy the state of the package after build has finished
      # FIXME: The log of `make check` is only shown at the end
      NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu="${toString (map (p: "-I${lib.getDev p}/include")
          (with pkgs; [libsodium jansson libgcrypt curl libgnurl libmicrohttpd libtool zlib]))}" \
        NIX_LDFLAGS_BEFORE_x86_64_unknown_linux_gnu="${toString (map (p: "-L${lib.getLib p}/lib")
          (with pkgs; [libsodium jansson libgcrypt curl libgnurl libmicrohttpd libtool postgresql libossp_uuid zlib]))}" \
        PKG_CONFIG_PATH="${lib.concatStringsSep ":" (map (p: "${lib.getDev p}/lib/pkgconfig")
          (with pkgs; [libmicrohttpd jansson]))}" \
        make check
    '';
  in ''
    start_all()
    client.wait_for_unit("multi-user.target")

    print('Copying the fixture and running `make check`')
    print('The log of `make check` will be shown at the end')
    print('Wait some long seconds (some postgres ERROR are expected but should probably be fixed) ...')
    # FIXME: follow the log
    client.log(client.execute("cd $HOME && set -x && ${check-anastasis}")[1])

    # The interesting part of the log is after "make check_TESTS"
    # i.e. lines containing "*test_anstasis_*"

    # FIXME:
    # src/cli/test_anastasis_reducer_enter_secret.sh
    # and src/cli/recovery_enter_user_attributes.sh
    # are skipped due to `line {65,64}: taler-bank-manage: command not found`
  '';
}
