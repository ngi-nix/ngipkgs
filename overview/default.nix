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
    toFile
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
    take
    drop
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
      ''
        <a href="https://github.com/ngi-nix/ngipkgs/tree/${self.rev}"><code>${self.shortRev}</code></a>
      ''
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

  # This function utilises IFD to harness the power of pandoc
  markdownToHtml =
    markdown:
    readFile (
      pkgs.runCommand "html" { nativeBuildInputs = with pkgs; [ pandoc ]; } ''
        pandoc --from=markdown --to=html ${toFile "md" markdown} > $out
      ''
    );

  render = {
    options = rec {
      one =
        prefixLength: option:
        let
          maybeDefault = optionalString (option ? default.text) ''
            <dt>Default:</dt>
            <dd class="option-default"><code>${option.default.text}</code></dd>
          '';
        in
        ''
          <dt class="option-name">
            <span class="option-prefix">${join "." (take prefixLength option.loc)}.</span><span>${join "." (drop prefixLength option.loc)}</span>
          </dt>
          <dd class="option-body">
            <div class="option-description">
            ${markdownToHtml option.description}
            </div>
            <dl>
              <dt>Type:</dt>
              <dd class="option-type"><code>${option.type}</code></dd>
              ${maybeDefault}
            </dl>
          </dd>
        '';
      many =
        projectOptions:
        let
          # The length of the attrs path that is common to all options
          # TODO: calculate automatically
          prefixLength = 2;
        in
        optionalString (!empty projectOptions) ''
          <section><details><summary>${heading 3 "Options"}</summary><dl>
          ${concatLines (map (one prefixLength) projectOptions)}
          </dl></details></section>
        '';
    };

    packages = rec {
      one = package: ''
        <dt><code>${package.name}</code></dt>
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

        <pre><code>${readFile example.path}</code></pre>

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
          <a href="https://nlnet.nl/project/${subgrant}">${subgrant}</a>
        </li>
      '';
      many =
        subgrants:
        optionalString (!empty subgrants) ''
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
        + (optionalString (metadata ? subgrants && metadata.subgrants != [ ]) ''
          <p>
            This project is funded by NLnet through these subgrants:

            ${render.subgrants.many metadata.subgrants}
          </p>
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
            <article>
              <a href="/project/${name}">${name}</a>
            </article>
          '') projects
        );
    };
  };

  # The top-level overview for all projects
  index = ''
    <section class="page-width">
      ${heading 1 "NGIpkgs"}

      <p>
        NGIpkgs is collection of software applications funded by the <a href="https://www.ngi.eu/ngi-projects/ngi-zero/">Next Generation Internet</a> initiative and packaged for <a href="https://nixos.org">NixOS</a>.
      </p>

      <p>
        This service is still <strong>experimental</strong> and under heavy development.
        Don't expect anything specific to work yet:
      </p>

      <ul>
        <li>The package collection is far incomplete</li>
        <li>Many packages lack crucial components</li>
        <li>There are no instructions for getting started</li>
        <li>How software and the corresponding Nix expressions are exposed is subject to change</li>
      </ul>

      <p>
        More information about the project:
      </p>

      <ul>
        <li>
          <a href="https://github.com/ngi-nix/ngipkgs">Source code</a>
        </li>
        <li>
          <a href="https://github.com/ngi-nix/summer-of-nix/issues/41">Issue tracker</a>
        </li>
        <li>
          <a href="https://nixos.org/community/teams/ngi/">Nix@NGI team</a>
        </li>
      </ul>

      <hr>

      ${render.projects.many projects}
    </section>

    <footer id="footer">Version: ${version}, Last Modified: ${lastModified}</footer>
  '';

  # Every HTML page that we generate
  pages =
    {
      "index.html" = {
        pagetitle = "NGIpkgs software repository";
        content = index;
      };
    }
    // mapAttrs' (
      name: project:
      nameValuePair "project/${name}/index.html" {
        pagetitle = "NGIpkgs | ${name}";
        content = render.projects.one name project;
      }
    ) projects;

  htmlFile =
    { ... }@args:
    let
    in
    pkgs.writeText "index.html" ''
      <!DOCTYPE html>
      <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en" dir="ltr">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
        <title>${args.pagetitle}</title>
        <link rel="stylesheet" href="/style.css">
      </head>
      <body>
      ${args.content}
      </body>
      </html>
    '';

  # Ensure that directories exist and that HTML is complete and works as a standalone file
  writeHtmlCommand = path: htmlFile: ''
    mkdir -p "$out/$(dirname '${path}')"
    ln -s '${htmlFile}' "$out/${path}"
  '';

  fonts =
    pkgs.runCommand "fonts"
      {
        nativeBuildInputs = with pkgs; [ woff2 ];
      }
      ''
        mkdir -vp $out
        cp -v ${pkgs.ibm-plex}/share/fonts/opentype/IBMPlex{Sans,Mono}-* $out/
        for otf in $out/*.otf; do
          woff2_compress "$otf"
        done
      '';

in
pkgs.runCommand "overview"
  {
    nativeBuildInputs = with pkgs; [
      jq
      validator-nu
    ];
  }
  (
    ''
      mkdir -pv $out
      cp -v ${./style.css} $out/style.css
      ln -s ${fonts} $out/fonts
    ''
    + (concatLines (mapAttrsToList (n: v: writeHtmlCommand n (htmlFile v)) pages))
    + ''

      vnu -Werror --format json $out/*.html | jq
    ''
  )
