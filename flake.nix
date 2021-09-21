{
  description = "GNU Anastasis is a key backup and recovery tool from the GNU project.";
  inputs.nixpkgs.url = "github:JosephLucas/nixpkgs/anastasis";
  outputs = { self, nixpkgs}:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

      ##
      # For the integration test
      ##
      anastasisSrc = let
         # FIXME: not sure if this prefetch to get some test data is conventional
         # FIXME: system should be generic here
         anastasisPkgName = ((import nixpkgs {system = "x86_64-linux";}).callPackage ./default.nix {}).name;
        in
          fetchTarball {
            url = "https://ftp.gnu.org/gnu/anastasis/${anastasisPkgName}.tar.gz";
            sha256 = "sha256:1lgpkjj4wy4xr34ngzi0qag1gspib3i9rmaw4g4k50l90jphzfxj";
          };
      sql0  =  builtins.readFile "${anastasisSrc}/src/stasis/stasis-0000.sql";
      sql1  =  builtins.readFile "${anastasisSrc}/src/stasis/stasis-0001.sql";
      t1  = "test_anastasis_reducer_backup_enter_user_attributes.sh";
      t2  = "test_anastasis_reducer_enter_secret.sh";
      t3  = "test_anastasis_reducer_recovery_enter_user_attributes.sh";

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
            jq
            anastasis
            postgresql
            taler-exchange
            taler-merchant
            wget # needed by test_anastasis_reducer_backup_enter_user_attributes.sh
          ];
          system.activationScripts.initFiles = ''
            # Load test fixture data into /tmp
            cp ${anastasisSrc}/src/cli/test_*.conf /tmp/
            ${pkgs.gnused}/bin/sed 's%#!/bin/bash%#!/usr/bin/env bash%g' "${anastasisSrc}/src/cli/${t1}" > /tmp/${t1}
            ${pkgs.gnused}/bin/sed 's%#!/bin/bash%#!/usr/bin/env bash%g' "${anastasisSrc}/src/cli/${t2}" > /tmp/${t2}
            ${pkgs.gnused}/bin/sed 's%#!/bin/bash%#!/usr/bin/env bash%g' "${anastasisSrc}/src/cli/${t3}" > /tmp/${t3}
            chmod +x /tmp/${t1} /tmp/${t2} /tmp/${t3}
          '';
        };
        db = { pkgs, ...}: {
          services.postgresql = {
            enable = true;
            initialScript = pkgs.writeText "initialScript.sql" (''
              create role root login createdb;
              CREATE DATABASE anastasischeck1 OWNER root;
              CREATE DATABASE anastasischeck2 OWNER root;
              CREATE DATABASE anastasischeck3 OWNER root;
              CREATE DATABASE anastasischeck4 OWNER root;
              '' 
              # NB: I hoped that one of these create the missing relation "_v.patches"
              + sql0
              + sql1
            ) ;
          };
        };
      };
      # FIXME: check also for x86_64-darwin as soon as Hydra will check darwin derivations
      checks.x86_64-linux.vmTest = with import (nixpkgs + "/nixos/lib/testing-python.nix") {system = "x86_64-linux";};
          makeTest {
            name = "anastasis-httpd";
            nodes = {
              client = { ... }: {
                imports = with self.nixosModules; [ db anastasis-httpd ];
              };
            };
            testScript = ''
              start_all()
              client.wait_for_unit("multi-user.target")
              client.log(client.execute("echo multi-user.target reached")[1])

              # Does not finish and yields:
              #   ERROR:  relation "_v.patches" does not exist at character 24
              #   client # [   14.273710] postgres[965]: [965] STATEMENT:  SELECT applied_by FROM _v.patches WHERE patch_name = $1 LIMIT 1
              client.wait_until_succeeds("cd /tmp/ && ./${t1}")

              # Does not finish and yields:
              #   ./test_anastasis_reducer_enter_secret.sh: line 65: taler-bank-manage: command not found
              # client.wait_until_succeeds("cd /tmp/ && ./${t2}")

              # Does not finish and yields:
              #   ./test_anastasis_reducer_recovery_enter_user_attributes.sh: line 64: taler-bank-manage: command not found
              # client.wait_until_succeeds("cd /tmp/ && ./${t3}")
            '';
        };
  };
}
