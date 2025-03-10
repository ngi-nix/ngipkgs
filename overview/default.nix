{
  lib,
  lib',
  options,
  pkgs,
  projects,
  self,
}:
let
  inherit (builtins)
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

  join = concatStringsSep;

  inherit (lib)
    concatLines
    flip
    foldl'
    hasPrefix
    mapAttrsToList
    optionalString
    recursiveUpdate
    mapAttrs'
    nameValuePair
    ;

  empty =
    xs:
    assert isList xs;
    xs == [ ];
  heading = i: text: "<h${toString i}>${text}</h${toString i}>";

  # Splits a compressed date up into ISO 8601
  lastModified =
    let
      sub = start: len: substring start len self.lastModifiedDate;
    in
    "${sub 0 4}-${sub 4 2}-${sub 6 2}T${sub 8 2}:${sub 10 2}:${sub 12 2}Z";

  version =
    if self ? rev then
      "[`${self.shortRev}`](https://github.com/ngi-nix/ngipkgs/tree/${self.rev})"
    else
      self.dirtyRev;

  pick = {
    options =
      project:
      let
        # string comparison is faster than collecting attribute paths as lists
        spec = attrNames (
          lib'.flattenAttrs "." (
            foldl' recursiveUpdate { } (
              mapAttrsToList (name: value: { ${name} = value; }) project.nixos.modules
            )
          )
        );
      in
      filter (option: any ((flip hasPrefix) (join "." option.loc)) spec) (attrValues options);
    examples = project: attrValues project.nixos.examples;
    packages = project: attrValues project.packages;
  };

  render = {
    options = rec {
      one =
        option:
        let
          maybeDefault = optionalString (option ? default.text) "`${option.default.text}`";
        in
        ''
          <dt>`${join "." option.loc}`</dt>
          <dd>
            <table>
              <tr>
                <td>Description:</td>
                <td>${lib.escapeXML option.description}</td>
              </tr>
              <tr>
                <td>Type:</td>
                <td>`${option.type}`</td>
              </tr>
              <tr>
                <td>Default:</td>
                <td>${maybeDefault}</td>
              </tr>
            </table>
          </dd>
        '';
      many =
        projectOptions:
        optionalString (!empty projectOptions) ''
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
      many =
        packages:
        optionalString (!empty packages) ''
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
      many =
        examples:
        optionalString (!empty examples) ''
          <section><details><summary>${heading 3 "Examples"}</summary><ul>
          ${concatLines (map one examples)}
          </ul></details></section>
        '';
    };

    projects = {
      one = name: project: ''
        ${heading 1 name}
        <https://nlnet.nl/project/${name}>

        ${render.packages.many (pick.packages project)}
        ${render.options.many (pick.options project)}
        ${render.examples.many (pick.examples project)}
      '';
      # Many projects are renderes as links to their individual project sites
      many =
        projects:
        concatLines (
          mapAttrsToList (name: _: ''
            <a href="${name}">${name}</a>
          '') projects
        );
    };
  };

  metadata = pkgs.writeText "metadata.json" (
    toJSON (
      import ./metadata.nix {
        date = lastModified;
      }
    )
  );

  # The top-level overview for all projects
  index = pkgs.writeText "index.html" ''
    ${render.projects.many projects}

    <hr>
    <footer>Version: ${version}, Last Modified: ${lastModified}</footer>
  '';

  # Every HTML page that we generate
  pages =
    {
      "index.html" = index;
    }
    // mapAttrs' (
      name: project:
      nameValuePair "${name}/index.html" (pkgs.writeText "index.html" (render.projects.one name project))
    ) projects;

  # Ensure that directories exist and that HTML is complete and works as a standalone file
  writeHtmlCommand = path: content: ''
    mkdir -p "$out/$(dirname '${path}')"

    pandoc \
      --from=markdown+raw_html \
      --to=html \
      --standalone \
      --css="/style.css" \
      --metadata-file=${metadata} \
      --output="$out/${path}" ${content}

    sed --file=${./fixup.sed} \
      --in-place \
      "$out/${path}"
  '';

in
pkgs.runCommand "overview"
  {
    nativeBuildInputs = with pkgs; [
      jq
      gnused
      pandoc
      validator-nu
    ];
  }
  (
    ''
      mkdir -v $out
      cp -v ${./style.css} $out/style.css
    ''
    + (concatLines (mapAttrsToList writeHtmlCommand pages))
    + ''

      vnu -Werror --format json $out/*.html | jq
    ''
  )
