let
  sources = (import ./flake-compat.nix { root = ./.; }).inputs;
in
{
  nixpkgs ? sources.nixpkgs,
  dream2nix ? sources.dream2nix,
  sops-nix ? sources.sops-nix,
}:
let
  self = import ./. { };
  lib = import "${nixpkgs}/lib";
  # TODO: we should be exporting our custom functions as `lib`, but refactoring
  # this to use `pkgs.lib` everywhere is a lot of movement
  lib' = import ./lib.nix { inherit lib; };
in
{
  # this depends on Nixpkgs specifics, in particular on arguments to the Nixpkgs entry point function,
  # and is therefore namespaced under `nixpkgs`
  nixpkgs =
    {
      system ? builtins.currentSystem,
      config ? { },
      overlays ? [ ],
      ...
    }@nixpkgs-config:
    let
      pkgs = import nixpkgs nixpkgs-config;
      dream2nix' = (import dream2nix).overrideInputs { inherit (sources) nixpkgs; };
      sops-nix' = import "${sops-nix}/modules/sops";
    in
    rec {
      inherit pkgs;

      ngipkgs = import ./pkgs/by-name {
        inherit pkgs lib;
        dream2nix = dream2nix';
      };

      overlays.default =
        final: prev:
        import ./pkgs/by-name {
          inherit lib;
          pkgs = prev;
          dream2nix = dream2nix';
        };

      raw-projects = import ./projects {
        inherit lib;
        pkgs = pkgs // ngipkgs;
        sources = {
          inputs = sources;
          modules = self.ngipkgs.nixos-modules;
          inherit (self.ngipkgs) examples;
        };
      };

      # TODO: find a better place for this
      projects =
        with lib;
        let
          nixosTest =
            test:
            let
              # Amenities for interactive tests
              tools =
                { pkgs, ... }:
                {
                  environment.systemPackages = with pkgs; [
                    vim
                    tmux
                    jq
                  ];
                  # Use kmscon <https://www.freedesktop.org/wiki/Software/kmscon/>
                  # to provide a slightly nicer console.
                  # kmscon allows zooming with [Ctrl] + [+] and [Ctrl] + [-]
                  services.kmscon = {
                    enable = true;
                    autologinUser = "root";
                  };
                };
              debugging.interactive.nodes = mapAttrs (_: _: tools) test.nodes;
            in
            pkgs.nixosTest (debugging // test);

          empty-if-null = x: if x != null then x else { };
          filter-map =
            attrs: input:
            lib.pipe attrs [
              (lib.concatMapAttrs (_: value: value."${input}" or { }))
              (lib.filterAttrs (_: v: v != null))
            ];

          hydrate =
            # we use fields to track state of completion.
            # - `null` means "expected but missing"
            # - not set means "not applicable"
            # TODO: encode this in types, either yants or the module system
            project: rec {
              metadata = empty-if-null (filterAttrs (_: m: m != null) (project.metadata or { }));
              nixos.modules.services = filterAttrs (_: m: m != null) (
                lib.mapAttrs (name: value: value.module or null) project.nixos.modules.services or { }
              );
              nixos.modules.programs = filterAttrs (_: m: m != null) (
                lib.mapAttrs (name: value: value.module or null) project.nixos.modules.programs or { }
              );
              # TODO: access examples for services and programs separately?
              nixos.examples = empty-if-null (
                (filter-map (project.nixos.modules.services or { }) "examples")
                // (filter-map (project.nixos.modules.programs or { }) "examples")
              );
              nixos.tests = mapAttrs (
                _: test:
                if lib.isString test then
                  (import test {
                    inherit pkgs;
                    inherit (pkgs) system;
                  })
                else if lib.isDerivation test then
                  test
                else
                  nixosTest test
              ) (filter-map (project.nixos or { }) "tests" // (filter-map (nixos.examples or { }) "tests"));
            };
        in
        mapAttrs (name: project: hydrate project) raw-projects;

      nixos-modules =
        with lib;
        # TODO: this is a weird shape for what we need: ngipkgs, services, modules?
        {
          # Allow using packages from `ngipkgs` to be used alongside regular `pkgs`
          ngipkgs =
            { ... }:
            {
              nixpkgs.overlays = [ overlays.default ];
            };
        }
        // foldl recursiveUpdate { } (map (project: project.nixos.modules) (attrValues projects));

      project-models = import ./projects/models.nix { inherit lib pkgs sources; };

      # we mainly care about the types being checked
      templates.project =
        let
          project-metadata =
            (project-models.project (import ./templates/project { inherit lib pkgs sources; })).metadata;
        in
        # fake derivation for flake check
        pkgs.writeText "dummy" (lib.strings.toJSON project-metadata);

      nixosSystem =
        args:
        import (nixpkgs + "/nixos/lib/eval-config.nix") (
          {
            inherit lib system;
          }
          // args
        );

      demo-system =
        module:
        nixosSystem {
          modules = [
            module
            (nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
            (nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
            (
              { config, ... }:
              {
                nixpkgs = {
                  # NOTE: `pkgs` is the evaluated packages based on evaluation-time paramaters to this file
                  inherit (pkgs.stdenv) buildPlatform hostPlatform;
                };

                users.users.nixos = {
                  isNormalUser = true;
                  extraGroups = [ "wheel" ];
                  initialPassword = "nixos";
                };

                users.users.root = {
                  initialPassword = "root";
                };

                security.sudo.wheelNeedsPassword = false;

                services.getty.autologinUser = "nixos";
                services.getty.helpLine = ''

                  Welcome to NGIpkgs!
                '';

                services.openssh = {
                  enable = true;
                  settings = {
                    PasswordAuthentication = true;
                    PermitEmptyPasswords = "yes";
                    PermitRootLogin = "yes";
                  };
                };

                system.stateVersion = "25.05";

                networking.firewall.enable = false;

                virtualisation = {
                  memorySize = 4096;
                  cores = 4;
                  graphics = false;

                  qemu.options = [
                    "-cpu host"
                    "-enable-kvm"
                  ];

                  # ssh + open service ports
                  forwardPorts = map (port: {
                    from = "host";
                    guest.port = port;
                    host.port = port + 10000;
                    proto = "tcp";
                  }) config.networking.firewall.allowedTCPPorts;
                };
              }
            )
          ] ++ self.ngipkgs.extendedNixosModules;
        };

      demo =
        module:
        pkgs.writeShellScript "demo-vm" ''
          exec ${(demo-system module).config.system.build.vm}/bin/run-nixos-vm "$@"
        '';

      # $ nix-build . -A demo-test
      # $ ./result
      demo-test = demo ./projects/Cryptpad/demo.nix;

      # TODO: find a better place for this
      metrics = with lib; {
        projects = attrNames raw-projects;
        in-ngipkgs = attrNames ngipkgs;
        derivations = concatMap (p: attrNames p.packages) (attrValues raw-projects);
        with-services = attrNames (
          filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects
        );
        missing-services = attrNames (
          filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services == null) raw-projects
        );
        services = concatMap attrNames (
          concatMap (p: attrValues p.nixos.modules) (
            attrValues (
              filterAttrs (name: p: p ? nixos.modules.services && p.nixos.modules.services != null) raw-projects
            )
          )
        );
        with-tests = attrNames (
          filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects
        );
        missing-tests = attrNames (
          filterAttrs (name: p: p ? nixos.tests && p.nixos.tests == null) raw-projects
        );
        tests = concatMap (p: attrNames p.nixos.tests) (
          attrValues (filterAttrs (name: p: p ? nixos.tests && p.nixos.tests != null) raw-projects)
        );
        with-examples = attrNames (
          filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects
        );
        missing-examples = attrNames (
          filterAttrs (name: p: p ? nixos.examples && p.nixos.examples == null) raw-projects
        );
        examples = concatMap (p: attrNames p.nixos.examples) (
          attrValues (filterAttrs (name: p: p ? nixos.examples && p.nixos.examples != null) raw-projects)
        );
      };

      metrics-count = with lib; mapAttrs (name: value: count (_: true) value) metrics;

      project-metrics =
        with lib;
        mapAttrs (
          _: p:
          {
            derivations = count (_: true) (attrNames p.packages);
          }
          // optionalAttrs (p ? nixos) {
            nixos =
              {
                tests = if p.nixos.tests == null then 0 else count (_: true) (attrNames p.nixos.tests);
                examples = if p.nixos.examples == null then 0 else count (_: true) (attrNames p.nixos.examples);
              }
              // optionalAttrs (p ? nixos.modules.services) {
                services =
                  if p.nixos.modules.services == null then
                    0
                  else
                    count (_: true) (attrNames p.nixos.modules.services);
              }
              // optionalAttrs (p ? nixos.modules.programs) {
                programs =
                  if p.nixos.modules.programs == null then
                    0
                  else
                    count (_: true) (attrNames p.nixos.modules.programs);
              };
          }
        ) raw-projects;

      shell = pkgs.mkShellNoCC {
        packages = [ ];
      };
    };

  ngipkgs =
    let
      # TODO: import this in examples directly
      sops-nix' = import "${sops-nix}/modules/sops";
    in
    rec {
      inherit lib lib';
      inherit (self) nixos-modules;

      rawNixosModules = (import ./lib.nix { inherit lib; }).flattenAttrs "." (
        lib.foldl lib.recursiveUpdate { } (
          lib.attrValues (lib.mapAttrs (_: project: project.nixos.modules) self.projects)
        )
      );

      extendedNixosModules =
        with lib;
        [
          nixos-modules.ngipkgs
          # TODO: needed for examples that use sops (like Pretalx)
          sops-nix'
        ]
        ++ attrValues nixos-modules.programs
        ++ attrValues nixos-modules.services;

      examples =
        with lib;
        mapAttrs (_: project: mapAttrs (_: example: example.module) project.nixos.examples) self.projects;
    };

  inherit (self.nixpkgs { })
    demo
    shell
    projects
    nixos-modules
    metrics
    metrics-count
    ;
  inherit (self.ngipkgs)
    rawNixosModules
    extendedNixosModules
    ;
}
