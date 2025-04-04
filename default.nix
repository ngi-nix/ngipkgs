{
  sources ? (import ./flake-compat.nix { root = ./.; }).inputs,
  system ? builtins.currentSystem,
  pkgs ? import sources.nixpkgs {
    config = { };
    overlays = [ ];
    inherit system;
  },
  lib ? import "${sources.nixpkgs}/lib",
}:
let
  dream2nix = (import sources.dream2nix).overrideInputs { inherit (sources) nixpkgs; };
  sops-nix = import "${sources.sops-nix}/modules/sops";
in
rec {
  inherit
    lib
    pkgs
    system
    sources
    ;

  # TODO: we should be exporting our custom functions as `lib`, but refactoring
  # this to use `pkgs.lib` everywhere is a lot of movement
  lib' = import ./lib.nix { inherit lib; };

  overlays.default =
    final: prev:
    import ./pkgs/by-name {
      pkgs = prev;
      inherit lib dream2nix;
    };

  examples =
    with lib;
    mapAttrs (_: project: mapAttrs (_: example: example.path) project.nixos.examples) projects;

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

  extendedNixosModules =
    with lib;
    [
      nixos-modules.ngipkgs
      # TODO: needed for examples that use sops (like Pretalx)
      sops-nix
    ]
    ++ attrValues nixos-modules.programs
    ++ attrValues nixos-modules.services;

  ngipkgs = import ./pkgs/by-name { inherit pkgs lib dream2nix; };

  raw-projects =
    let
      project-inputs = {
        inherit lib;
        pkgs = pkgs // ngipkgs;
        sources = {
          inputs = sources;
          modules = nixos-modules;
          inherit examples;
        };
      };
      new-project-to-old =
        new-project:
        let
          empty-if-not-attrs = x: if lib.isAttrs x then x else { };
          removeNull = a: lib.filterAttrs (_: v: v != null) a;

          services = empty-if-not-attrs (new-project.nixos.modules.services or { });
          programs = empty-if-not-attrs (new-project.nixos.modules.programs or { });

          get = func: attrs: lib.concatMapAttrs (_: value: func value) attrs;

          examples-from =
            value:
            if (value ? examples) && (lib.isAttrs value.examples) then
              lib.mapAttrs (
                _: example:
                if lib.isAttrs example then
                  {
                    path = example.module;
                    description = example.description;
                  }
                else
                  null
              ) value.examples
            else
              { };
          tests-from =
            value:
            if (value ? tests) && (lib.isAttrs value.tests) then
              value.tests
            else if (value ? examples) && (lib.isAttrs value.examples) then
              lib.concatMapAttrs (_: example: example.tests or { }) value.examples
            else
              { };
        in
        {
          packages = { }; # NOTE: the overview expects a set
          metadata = new-project.metadata or { };
          nixos.modules.services = removeNull (lib.mapAttrs (name: value: value.module or null) services);
          nixos.modules.programs = removeNull (lib.mapAttrs (name: value: value.module or null) programs);
          nixos.examples = removeNull (
            examples-from new-project.nixos // get examples-from services // get examples-from programs
          );
          nixos.tests = removeNull (
            tests-from new-project.nixos // get tests-from services // get tests-from programs
          );
        };
      map-new-projects = projects: lib.mapAttrs (name: value: new-project-to-old value) projects;
    in
    import ./projects-old project-inputs // map-new-projects (import ./projects project-inputs);

  project-models = import ./projects/models.nix { inherit lib pkgs sources; };

  templates.project = project-models.project (
    import ./templates/project { inherit lib pkgs sources; }
  );

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

      hydrate =
        # we use fields to track state of completion.
        # - `null` means "expected but missing"
        # - not set means "not applicable"
        # TODO: encode this in types, either yants or the module system
        project: {
          packages = empty-if-null (filterAttrs (name: value: value != null) (project.packages or { }));
          metadata = empty-if-null (filterAttrs (name: value: value != null) (project.metadata or { }));
          nixos.modules = empty-if-null (filterAttrs (_: m: m != null) (project.nixos.modules or { }));
          nixos.examples = empty-if-null (project.nixos.examples or { });
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
          ) (empty-if-null (project.nixos.tests or { }));
        };
    in
    mapAttrs (name: project: hydrate project) raw-projects;

  shell = pkgs.mkShellNoCC {
    packages = [ ];
  };

  demo-system =
    module:
    let
      nixosSystem =
        args:
        import (sources.nixpkgs + "/nixos/lib/eval-config.nix") (
          {
            inherit lib;
            system = null;
          }
          // args
        );
    in
    nixosSystem {
      system = "x86_64-linux";
      modules = [
        module
        (sources.nixpkgs + "/nixos/modules/profiles/qemu-guest.nix")
        (sources.nixpkgs + "/nixos/modules/virtualisation/qemu-vm.nix")
        (
          { config, ... }:
          {
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

              Welcome to Ngipkgs!
            '';

            virtualisation = {
              memorySize = 4096;
              cores = 4;
              graphics = false;
              diskImage = null;

              qemu.options = [
                "-cpu host"
                "-enable-kvm"
              ];

              # ssh + open service ports
              forwardPorts = map (port: {
                from = "host";
                guest.port = port;
                host.port = port;
                proto = "tcp";
              }) config.networking.firewall.allowedTCPPorts;
            };

            services.openssh = {
              enable = true;
              ports = lib.mkDefault [ 2222 ];
              settings = {
                PasswordAuthentication = true;
                PermitEmptyPasswords = "yes";
                PermitRootLogin = "yes";
              };
            };

            system.stateVersion = "25.05";

            networking.firewall.enable = false;
          }
        )
      ] ++ extendedNixosModules;
    };

  demo =
    module:
    pkgs.writeShellScript "demo-vm" ''
      ${(demo-system module).config.system.build.vm}/bin/run-nixos-vm
    '';

  # $ nix-build . -A demo-test
  # $ ./result
  demo-test = demo ./projects/Cryptpad/demo.nix;
}
