{
  lib,
  options,
  pkgs,
  projects,
  self,
}: let
  lib' = import ../lib.nix {inherit lib;};

  inherit
    (builtins)
    any
    attrNames
    attrValues
    concatStringsSep
    filter
    isList
    readFile
    substring
    toJSON
    toString
    ;

  inherit
    (lib)
    concatLines
    flip
    hasPrefix
    mapAttrsToList
    optionalString
    splitString
    ;

  inherit
    (lib')
    flattenAttrsDot
    ;

  empty = xs: assert isList xs; xs == [];
  heading = i: text: "<h${toString i}>${text}</h${toString i}>";
  dottedLoc = option: concatStringsSep "." option.loc;

  # Splits a compressed date up into ISO 8601
  lastModified = let
    sub = start: len: substring start len self.lastModifiedDate;
  in "${sub 0 4}-${sub 4 2}-${sub 6 2}T${sub 8 2}:${sub 10 2}:${sub 12 2}Z";

  version =
    if self ? rev
    then "[`${self.shortRev}`](https://github.com/ngi-nix/ngipkgs/tree/${self.rev})"
    else self.dirtyRev;

  pick = {
    options = project: let
      spec = attrNames (flattenAttrsDot (project.nixos.modules or {}));
    in
      filter
      (option: any ((flip hasPrefix) (dottedLoc option)) spec)
      (attrValues options);
    examples = project: attrValues (project.nixos.examples or {});
    packages = project: attrValues (project.packages or {});
  };

  render = {
    options = rec {
      one = value: let
        maybeDefault = optionalString (value ? default.text) "`${value.default.text}`";
      in ''
        <dt>`${dottedLoc value}`</dt>
        <dd>
          <table>
            <tr>
              <td>Description:</td>
              <td>${value.description}</td>
            </tr>
            <tr>
              <td>Type:</td>
              <td>`${value.type}`</td>
            </tr>
            <tr>
              <td>Default:</td>
              <td>${maybeDefault}</td>
            </tr>
          </table>
        </dd>
      '';
      many = projectOptions:
        optionalString (!empty projectOptions)
        ''
          <section><details><summary>${heading 3 "Options"}</summary><dl>
          ${concatLines (map one projectOptions)}
          </dl></details></section>
        '';
    };

    packages = rec {
      one = package: ''
        <dt>`${package.name}`</dt>
        <dd>
          <table>
            <tr>
              <td>Version:</td>
              <td>${package.version}</td>
            </tr>
          </table>
        </dd>
      '';
      many = packages:
        optionalString (!empty packages)
        ''
          <section><details><summary>${heading 3 "Packages"}</summary><dl>
          ${concatLines (map one packages)}
          </dl></details></section>
        '';
    };

    examples = rec {
      one = example: ''
        <li>

        ${example.description}

        ```nix
        ${readFile example.path}
        ```

        </li>
      '';
      many = examples:
        optionalString (!empty examples)
        ''
          <section><details><summary>${heading 3 "Examples"}</summary><ul>
          ${concatLines (map one examples)}
          </ul></details></section>
        '';
    };

    projects = rec {
      one = name: project: ''
        <section><details><summary>${heading 2 name}</summary>
        <https://nlnet.nl/project/${name}>

        ${render.packages.many (pick.packages project)}
        ${render.options.many (pick.options project)}
        ${render.examples.many (pick.examples project)}
        </details></section>
      '';
      many = projects: concatLines (mapAttrsToList one projects);
    };
  };

  metadata = pkgs.writeText "metadata.json" (toJSON (import ./metadata.nix {
    date = lastModified;
  }));

  content = pkgs.writeText "overview.html" ''
    ${render.projects.many projects}

    <hr>
    <footer>Version: ${version}, Last Modified: ${lastModified}</footer>
  '';
in
  pkgs.runCommand "overview" {
    nativeBuildInputs = with pkgs; [jq gnused pandoc validator-nu];
  } ''
    mkdir -v $out
    cp -v ${./style.css} $out/style.css

    pandoc \
      --from=markdown+raw_html \
      --to=html \
      --standalone \
      --css="style.css" \
      --metadata-file=${metadata} \
      --output=$out/index.html ${content}

    sed --file=${./fixup.sed} \
      --in-place \
      $out/index.html

    vnu -Werror --format json $out/*.html 2>&1 | jq
  ''
