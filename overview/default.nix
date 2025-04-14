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
                <td>${option.description}</td>
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

    subgrants = rec {
      one = subgrant: ''
        <li>
          <https://nlnet.nl/project/${subgrant}>
        </li>
      '';
      many =
        subgrants:
        optionalString (subgrants != [ ]) ''
          <ul>
            ${concatLines (map one subgrants)}
          </ul>
        '';
    };

    metadata = rec {
      one =
        metadata:
        (optionalString (metadata ? summary) ''
          <p>
            ${metadata.summary}
          </p>
        '')
        + (optionalString (metadata ? subgrants) ''
          ${render.subgrants.many metadata.subgrants}
        '');
    };

    projects = {
      one = name: project: ''
        <article class="page-width">
          ${heading 1 name}
          ${render.metadata.one project.metadata}
          ${render.packages.many (pick.packages project)}
          ${render.options.many (pick.options project)}
          ${render.examples.many (pick.examples project)}
        </article>
      '';
      # Many projects are rendered as links to their individual project sites
      many =
        projects:
        concatLines (
          mapAttrsToList (name: _: ''
            <a href="/project/${name}">${name}</a>
          '') projects
        );
    };
  };

  # The top-level overview for all projects
  index = pkgs.writeText "index.html" ''
    <article class="page-width">
    # NGIpkgs

    NGIpkgs is collection of software applications funded by the <a href="https://www.ngi.eu/ngi-projects/ngi-zero/">Next Generation Internet</a> initiative and packaged for <a href="https://nixos.org">NixOS</a>.

    This service is still <strong>experimental</strong> and under active development.
    Don't expect anything specific to work yet:

    - The package collection is steadily growing
    - Many packages are in development, with ongoing efforts to complete their components
    - We’re preparing instructions to make getting started as smooth as possible
    - The way to expose our software and its Nix expressions is evolving, as we continue to refine the user experience

    More information about the project:

    - [Source code](https://github.com/ngi-nix/ngipkgs)
    - [Issue tracker](https://github.com/ngi-nix/summer-of-nix/issues/41)
    - [Nix@NGI team](https://nixos.org/community/teams/ngi/)

    ---

    ${render.projects.many projects}

    </article>

    <footer>Version: ${version}, Last Modified: ${lastModified}</footer>
  '';

  # Every HTML page that we generate
  pages =
    {
      "index.html" = {
        pagetitle = "NGIpkgs software repository";
        html = index;
      };
    }
    // mapAttrs' (
      name: project:
      nameValuePair "project/${name}/index.html" {
        pagetitle = "NGIpkgs | ${name}";
        html = pkgs.writeText "index.html" (render.projects.one name project);
      }
    ) projects;

  # Ensure that directories exist and that HTML is complete and works as a standalone file
  writeHtmlCommand =
    path:
    { pagetitle, html, ... }:
    let
      metadata = pkgs.writeText "metadata.json" (toJSON {
        inherit pagetitle;
        date = lastModified;
        lang = "en";
        dir = "ltr";
      });
    in
    ''
      mkdir -p "$out/$(dirname '${path}')"

      pandoc \
        --from=markdown+raw_html \
        --to=html \
        --standalone \
        --css="/style.css" \
        --metadata-file=${metadata} \
        --output="$out/${path}" ${html}

      sed --file=${./fixup.sed} \
        --in-place \
        "$out/${path}"
    '';

  fonts =
    pkgs.runCommand "fonts"
      {
        nativeBuildInputs = with pkgs; [ woff2 ];
      }
      ''
        mkdir -vp $out
        cp -v ${pkgs.ibm-plex}/share/fonts/opentype/IBMPlexSans-* $out/
        for otf in $out/*.otf; do
          woff2_compress "$otf"
        done
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
      mkdir -pv $out
      cp -v ${./style.css} $out/style.css
      ln -s ${fonts} $out/fonts
    ''
    + (concatLines (mapAttrsToList writeHtmlCommand pages))
    + ''

      vnu -Werror --format json $out/*.html | jq
    ''
  )
