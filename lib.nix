{ lib }:
rec {
  # Take an attrset of arbitrary nesting and make it flat
  # by concatenating the nested names with the given separator.
  flattenAttrs =
    separator:
    let
      f = path: lib.concatMapAttrs (flatten path);
      flatten =
        path: name: value:
        if lib.isAttrs value then f (path + name + separator) value else { ${path + name} = value; };
    in
    f "";

  /*
      *
    Convert number of seconds in the Unix epoch to a Gregorian calendar date and time

    This does not take into account leap seconds, which would require a table lookup.
  */
  datetime-from-timestamp =
    timestamp:
    let
      remainder = x: y: x - x / y * y;
      seconds-per-day = 86400;
      day-of-epoch = timestamp / seconds-per-day;
      seconds-of-day = remainder timestamp seconds-per-day;
      hours = seconds-of-day / 3600;
      minutes = (remainder seconds-of-day 3600) / 60;
      seconds = remainder timestamp 60;

      # Courtesy of http://howardhinnant.github.io/date_algorithms.html via https://stackoverflow.com/a/32158604
      day' = day-of-epoch + 719468; # internal representation of days, based on number of days between 0000-03-01 and 1970-01-01
      days-per-era = 146097;
      era =
        # 400-year interval of the Gregorian calendar
        (if day' >= 0 then day' else day' - (days-per-era - 1)) / days-per-era;
      day-of-era = day' - era * days-per-era;
      year-of-era =
        (day-of-era - day-of-era / 1460 + day-of-era / 36524 - day-of-era / (days-per-era - 1)) / 365;
      year' = year-of-era + era * 400; # internal representation of years
      day-of-year = day-of-era - (365 * year-of-era + year-of-era / 4 - year-of-era / 100);
      month' = (5 * day-of-year + 2) / 153; # internal representation of months
      day = day-of-year - (153 * month' + 2) / 5 + 1;
      month = month' + (if month' < 10 then 3 else -9);
      year = year' + (if month <= 2 then 1 else 0);
    in
    {
      inherit
        year
        month
        day
        hours
        minutes
        seconds
        ;
    };

  # Format number of seconds in the Unix epoch as %Y%m%d%H%M%S.
  format-timestamp =
    timestamp:
    let
      pad =
        n: s:
        let
          str = toString s;
        in
        with builtins;
        concatStringsSep "" (genList (_: "0") (n - stringLength str)) + str;
    in
    with builtins.mapAttrs (name: s: if name == "year" then pad 4 s else pad 2 s) (
      datetime-from-timestamp timestamp
    );
    "${year}${month}${day}${hours}${minutes}${seconds}";

  /*
      *
    Polyfill for the experimental `builtins.fetchTree`

    https://nix.dev/manual/nix/latest/language/builtins#builtins-fetchTree
  */
  fetchTree =
    info:
    if info.type == "github" then
      {
        outPath = fetchTarball (
          {
            url = "https://api.${info.host or "github.com"}/repos/${info.owner}/${info.repo}/tarball/${info.rev}";
          }
          // (if info ? narHash then { sha256 = info.narHash; } else { })
        );
        rev = info.rev;
        shortRev = builtins.substring 0 7 info.rev;
        lastModified = info.lastModified;
        lastModifiedDate = format-timestamp info.lastModified;
        narHash = info.narHash;
      }
    else if info.type == "git" then
      {
        outPath = builtins.fetchGit (
          {
            url = info.url;
            shallow = true;
            allRefs = true;
          }
          // (if info ? rev then { inherit (info) rev; } else { })
          // (if info ? submodules then { inherit (info) submodules; } else { })
        );
        lastModified = info.lastModified;
        lastModifiedDate = format-timestamp info.lastModified;
        narHash = info.narHash;
      }
      // (
        if info ? rev then
          {
            rev = info.rev;
            shortRev = builtins.substring 0 7 info.rev;
          }
        else
          { }
      )
    else if info.type == "path" then
      {
        outPath = builtins.path {
          path =
            if
              builtins.substring 0 1 info.path != "/"
            # XXX: relative paths require an additional `root` attribute!
            #      this is supplied by our own flake-inputs, but may not work elsewhere
            then
              "${info.root}/${info.path}"
            else
              info.path;
        };
        narHash = info.narHash;
      }
    else if info.type == "tarball" then
      {
        outPath = fetchTarball (
          { inherit (info) url; } // (if info ? narHash then { sha256 = info.narHash; } else { })
        );
      }
    else if info.type == "gitlab" then
      {
        inherit (info) rev narHash lastModified;
        outPath = fetchTarball (
          {
            url = "https://${info.host or "gitlab.com"}/api/v4/projects/${info.owner}%2F${info.repo}/repository/archive.tar.gz?sha=${info.rev}";
          }
          // (if info ? narHash then { sha256 = info.narHash; } else { })
        );
        shortRev = builtins.substring 0 7 info.rev;
      }
    # TODO: Mercurial, tarball inputs, ...
    else
      throw "flake input has unsupported input type '${info.type}'";

  /*
    *
    Compatibility layer to allow `flake.lock` files to be used with stable Nix.

    Modified from https://github.com/nix-community/dream2nix/blob/main/dev-flake/flake-compat.nix
    https://github.com/nix-community/flake-compat is not actively maintained
  */
  flake-inputs =
    {
      root,
      overrides ? { },
    }:
    let
      lockFilePath = root + "/flake.lock";
      lockFile = builtins.fromJSON (builtins.readFile lockFilePath);

      tree =
        let
          # Try to clean the source tree by using fetchGit, if this source
          # tree is a valid git repository.
          tryFetchGit =
            src:
            if isGit && !isShallow then
              let
                res = builtins.fetchGit src;
              in
              if res.rev == "0000000000000000000000000000000000000000" then
                removeAttrs res [
                  "rev"
                  "shortRev"
                ]
              else
                res
            else
              { outPath = src; };
          # NB git worktrees have a file for .git, so we don't check the type of .git
          isGit = builtins.pathExists (root + "/.git");
          isShallow = builtins.pathExists (root + "/.git/shallow");
        in
        {
          lastModified = 0;
          lastModifiedDate = format-timestamp 0;
        }
        // (if root ? outPath then root else tryFetchGit root);

      # we can't import those from the Nixpkgs `lib`,
      # since flake inputs are used to fetch Nixpkgs to begin with
      nameValuePair = name: value: { inherit name value; };
      mapAttrs' = f: set: builtins.listToAttrs (map (attr: f attr set.${attr}) (builtins.attrNames set));

      rootOverrides = mapAttrs' (
        input: lockKey':
        let
          lockKey = if builtins.isList lockKey' then builtins.concatStringsSep "/" lockKey' else lockKey';
        in
        nameValuePair lockKey (overrides.${input} or null)
      ) lockFile.nodes.${lockFile.root}.inputs;

      allNodes = builtins.mapAttrs (
        key: node:
        let
          sourceInfo =
            if key == lockFile.root then
              tree
            else if rootOverrides.${key} or null != null then
              {
                type = "path";
                outPath = rootOverrides.${key};
                narHash = throw "flake-inputs: overriding narHash not implemented";
              }
            else
              fetchTree (node.info or { } // removeAttrs node.locked [ "dir" ] // { inherit root; });

          inputs = builtins.mapAttrs (_inputName: inputSpec: allNodes.${resolveInput inputSpec}) (
            node.inputs or { }
          );

          # Resolve a input spec into a node name.
          # An input spec is either a node name, or a 'follows' path from the root node.
          resolveInput =
            inputSpec: if builtins.isList inputSpec then getInputByPath lockFile.root inputSpec else inputSpec;

          # Follow an input path (e.g. ["dwarffs" "nixpkgs"]) from the root node, returning the final node.
          getInputByPath =
            nodeName: path:
            if path == [ ] then
              nodeName
            else
              getInputByPath
                # Since this could be a 'follows' input, call resolveInput.
                (resolveInput lockFile.nodes.${nodeName}.inputs.${builtins.head path})
                (builtins.tail path);
        in
        sourceInfo
        // {
          inherit inputs;
          inherit sourceInfo;
          _type = "flake";
        }
      ) lockFile.nodes;
    in
    if lockFile.version >= 5 && lockFile.version <= 7 then
      allNodes.${lockFile.root}
      // {
        overrideInputs =
          ov:
          flake-inputs {
            inherit root;
            overrides = ov;
          };
      }
    else
      throw "flake-inputs: lock file '${lockFilePath}' has unsupported version ${toString lockFile.version}";
}
