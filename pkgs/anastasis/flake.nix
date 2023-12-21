{
  description = "GNU Anastasis is a key backup and recovery tool from the GNU project.";
  inputs.nixpkgs.url = "github:JosephLucas/nixpkgs/anastasis";

  outputs = { self, nixpkgs}:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in
    {
      overlay = final: prev: { anastasis = (final.callPackage ./default.nix {}); };
      packages = forAllSystems (system: { inherit (nixpkgsFor.${system}) anastasis; });
      defaultPackage = forAllSystems (system: self.packages.${system}.anastasis);
      devShell = self.defaultPackage;
      checks.x86_64-linux.anastasis-build = self.packages.x86_64-linux.anastasis;

      ###
      # Integration test:
      #   anstasis + gnunet + postgres + taler-exchange + taler-merchant
      ###
      nixosModules = {
        anastasis-httpd = { pkgs, ... }: {
          nixpkgs.overlays = [ self.overlay ];
          systemd.services.anastasis-httpd = {
            wantedBy = [ "multi-user.target" ];
            serviceConfig.ExecStart = ''
              ${pkgs.anastasis}/bin/anastasis-httpd
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
            gnumake automake autoconf autoconf-archive autoconf-archive
            pkg-config
            libgcrypt.dev
            gcc
          ];
        };
        db = { pkgs, ...}: {
          services.postgresql = {
            enable = true;
            initialScript = pkgs.writeText "initialScript.sql" (''
              create role root login createdb;
              ''
            ) ;
          };
        };
      };
      checks.x86_64-linux.vmTest = with import (nixpkgs + "/nixos/lib/testing-python.nix") {system = "x86_64-linux";};
          makeTest {
            name = "anastasis-httpd";
            nodes = {
              client = { ... }: {
                imports = with self.nixosModules; [ db anastasis-httpd ];
              };
            };
            testScript = let
              check-anastasis = pkgs.writeScript "check-anastasis" ''
                # Load test fixture data into the vm $HOME (/root)
                cd ${self.packages.x86_64-linux.anastasis.configured} && find . -type f -exec install -Dm 755 "{}" "$HOME/{}" \;
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
                NIX_CFLAGS_COMPILE_BEFORE_x86_64_unknown_linux_gnu="-I${pkgs.libsodium.dev}/include -I${pkgs.jansson}/include -I${pkgs.libgcrypt.dev}/include -I${pkgs.curl.dev}/include -I${pkgs.libgnurl}/include -I${pkgs.libmicrohttpd.dev}/include -I${pkgs.libtool}/include -I${pkgs.zlib.dev}/include" NIX_LDFLAGS_BEFORE_x86_64_unknown_linux_gnu="-L${pkgs.libsodium}/lib -L${pkgs.jansson}/lib -L${pkgs.libgcrypt}/lib -L${pkgs.curl}/lib -L${pkgs.libgnurl}/lib -L${pkgs.libmicrohttpd}/lib -L${pkgs.libtool.lib}/lib -L${pkgs.postgresql.lib}/lib -L${pkgs.libossp_uuid}/lib -L${pkgs.zlib}/lib" PKG_CONFIG_PATH="${pkgs.libmicrohttpd.dev}/lib/pkgconfig:${pkgs.jansson}/lib/pkgconfig" make check
                '';
                in
              ''
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
        };
  };
}
