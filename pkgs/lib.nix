{
  lib,
  sources,
  system,
  ...
}@args:
rec {
  /*
    Adapted from `lib.customisation.makeScope`:
    https://nixos.org/manual/nixpkgs/stable/#function-library-lib.customisation.makeScope

    # Usage
    - `fix`: compute the result of the final scope
    - `call`: return an overridable result (e.g. packages that should be customizable)
    - `import`: return a non-overridable result (e.g. top-level imports)
  */
  customScope =
    newScope: f:
    let
      self = f self // {
        newScope = scope: newScope (self // scope);
        overrideScope = g: customScope newScope (lib.extends g f);

        # Compute a scope's fixpoint using `callPackage`
        # Example: finalScope = scope.fix scope;
        # See: https://nixos.org/manual/nixpkgs/unstable/#sec-functions-library-fixedPoints
        fix = f;

        # Similar to `pkgs.callPackage`, but aware of `default` scope attributes.
        # The result is overridable.
        call = self.newScope {
          nixdoc-to-github = self.callPackage sources.nixdoc-to-github { };
          dream2nix = sources.dream2nix;
          hillingar = sources.hillingar.lib.${system};
        };

        callPackage = self.call;

        # Similar to `import`, but aware of `default` scope attributes.
        # The result is not overridable.
        import =
          file: args:
          let
            result = self.call file args;
          in
          if lib.isAttrs result then
            removeAttrs result [
              "override"
              "overrideDerivation"
            ]
          else
            # Other results are expected for certain cases (e.g. functions).
            result;
      };
    in
    self;

  # Take an attrset of arbitrary nesting and make it flat
  # by concatenating the nested names with the given separator.
  flattenAttrs =
    separator:
    let
      f = path: lib.concatMapAttrs (flatten path);
      flatten =
        path: name: value:
        if (lib.isAttrs value) && (!lib.isDerivation value) then
          f (path + name + separator) value
        else
          { ${path + name} = value; };
    in
    f "";

  filter-map =
    attrs: input:
    lib.pipe attrs [
      (lib.concatMapAttrs (_: value: value."${input}" or { }))
      (lib.filterAttrs (_: v: v != null))
    ];

  join = lib.concatStringsSep;

  indent =
    prefix: s:
    with lib.lists;
    let
      lines = lib.splitString "\n" s;
    in
    join "\n" ([ (head lines) ] ++ (map (x: if x == "" then x else "${prefix}${x}") (tail lines)));

  # Recursively evaluate attributes for an attribute set.
  # Coupled with an evaluated nixos configuration, this presents an efficient
  # way for checking module types.
  forceEvalRecursive =
    attrs:
    lib.mapAttrsRecursive (
      n: v:
      if lib.isList v then
        map (
          i:
          # if eval fails
          if !(builtins.tryEval i).success then
            # recursively recurse into attrsets
            if lib.isAttrs i then forceEvalRecursive i else (builtins.tryEval i).success
          else
            (builtins.tryEval i).success
        ) v
      else
        (builtins.tryEval v).success
    ) attrs;

  # get the path of NixOS module from string
  # example:
  # moduleLocFromOptionString "services.ntpd-rs"
  # => "/nix/store/...-source/nixos/modules/services/networking/ntp/ntpd-rs.nix"
  moduleLocFromOptionString =
    let
      inherit
        (lib.evalModules {
          class = "nixos";
          specialArgs.modulesPath = "${sources.nixpkgs}/nixos/modules";
          modules = [
            { nixpkgs.hostPlatform = system; }
          ]
          ++ import "${sources.nixpkgs}/nixos/modules/module-list.nix";
        })
        options
        ;
    in
    opt:
    let
      locList = lib.splitString "." opt;
      optAttrs = lib.getAttrFromPath locList options;

      # collect all file paths from all options
      collectFiles =
        attrs:
        let
          # get value of `files` attr or empty list
          getFiles =
            attr: if attr.value ? files && builtins.isList attr.value.files then attr.value.files else [ ];
        in
        lib.concatMap getFiles (lib.attrsToList attrs);
    in
    lib.head (collectFiles optAttrs);
}
