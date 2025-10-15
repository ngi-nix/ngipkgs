{
  lib,
  newScope,
  ocaml-ng,
}:

let
  ocamlPackages = ocaml-ng.ocamlPackages_5_2;

  # A scope automatically makes attributes available as arguments
  # https://nixos.org/manual/nixpkgs/unstable/#function-library-lib.customisation.makeScope
  deps = lib.makeScope newScope (
    self:
    let
      callPackage = self.newScope { inherit ocamlPackages; };
    in
    {
      _0wm-server = callPackage ./0wm-server.nix {
        # pass dependencies to `_0wm-server.passthru.deps`
        deps = self;
      };

      gendarme = callPackage ./gendarme.nix { };

      gendarme-ezjsonm = callPackage ./gendarme-ezjsonm.nix { };

      gendarme-json = callPackage ./gendarme-json.nix { };

      gendarme-toml = callPackage ./gendarme-toml.nix { };

      gendarme-yaml = callPackage ./gendarme-yaml.nix { };

      gendarme-yojson = callPackage ./gendarme-yojson.nix { };

      ppx_marshal = callPackage ./ppx_marshal.nix { };

      ppx_marshal_ext = callPackage ./ppx_marshal_ext.nix { };
    }
  );
in
# We're only interested in the server pacakge, but dependencies are passed to
# the final output (`_0wm-server.passthru.deps`) in case we need them
deps._0wm-server
