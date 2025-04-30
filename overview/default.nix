{
  lib,
  lib',
  options,
  nixpkgs,
  pkgs,
  projects,
  self,
  system,
}:
let
  inherit (builtins)
    any
    attrNames
    attrValues
    concatStringsSep
    filter
    isList
    isInt
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
    filterAttrs
    mapAttrs'
    nameValuePair
    take
    drop
    splitString
    intersperse
    ;

  empty =
    xs:
    assert isList xs;
    xs == [ ];
  heading =
    i: anchor: text:
    assert (isInt i && i > 0);
    if i == 1 then
      ''
        <h1>${text}</h1>
      ''
    else
      ''
        <a class="heading" href="#${anchor}">
          <h${toString i} data-url="#${anchor}">
            ${text}
            <span class="anchor"/>
          </h${toString i}>
        </a>
      '';

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
    examples = project: attrValues (filterAttrs (name: _: name != "demo") project.nixos.examples);
  };

  # This doesn't actually produce a HTML string but a Jinja2 template string
  # literal, that is then replaced by it's HTML translation at the last build
  # step.
  markdownToHtml = markdown: "{{ markdown_to_html(${toJSON markdown}) }}";

  render = {
    # A code snippet that is copyable and optionally downloadable
    codeSnippet.one =
      {
        filename,
        language ? "nix",
        relative ? false,
        downloadable ? false,
      }:
      ''
        <div class="code-block">
          {{ include_code("${language}", "${filename}" ${optionalString relative ", relative_path=True"}) }}
          <div class="code-buttons">
            ${optionalString downloadable ''
              <a class="button download" href="${filename}" download>Download</a>
            ''}
            <button class="button copy" onclick="copyToClipboard(this, '${filename}')">
                ${optionalString (!relative) ''
                  <script type="application/json">
                    ${toJSON (readFile filename)}
                  </script>
                ''}
                Copy
            </button>
          </div>
        </div>
      '';
    options = rec {
      one =
        prefixLength: option:
        let
          maybeDefault = optionalString (option ? default.text) ''
            <dt>Default:</dt>
            <dd class="option-default"><code>${option.default.text}</code></dd>
          '';
          maybeReadonly = optionalString option.readOnly ''
            <span class="option-readonly" title="This option can't be set by users">Read-only</span>
          '';
        in
        ''
          <dt class="option-name">
            <span class="option-prefix">${join "." (take prefixLength option.loc)}.</span><span>${join "." (drop prefixLength option.loc)}</span>
            ${maybeReadonly}
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
          ${heading 2 "options" "Options"}
          <section><details><summary><code>services.cryptpad</code></summary><dl>
          ${concatLines (map (one prefixLength) projectOptions)}
          </dl></details></section>
        '';
    };

    examples = rec {
      one = example: ''
        <section><details><summary>${example.description}</summary>

        ${render.codeSnippet.one { filename = example.module; }}

        </details></section>
      '';
      many =
        examples:
        optionalString (!empty examples) ''
          ${heading 2 "examples" "Examples"}
          ${concatLines (map one examples)}
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

    # The indivdual page of a project
    projects.one = name: project: ''
      <article class="page-width">
        ${heading 1 null name}
        ${render.metadata.one project.metadata}
        ${optionalString (project.nixos.examples ? demo) (
          render.serviceDemo.one project.nixos.modules.services project.nixos.examples.demo
        )}
        ${render.options.many (pick.options project)}
        ${render.examples.many (pick.examples project)}
      </article>
    '';

    deliverableTags = rec {
      one = label: ''
        <span class="deliverable-tag">${label}</span>
      '';
      many =
        project:
        # TODO is missing in the model yet
        optionalString false (one "library")
        + optionalString (project.nixos.modules ? services && project.nixos.modules.services != { }) (
          one "service"
        )
        +
          # TODO is supposed to represent GUI apps and needs to be distinguished from CLI applications
          optionalString false (one "application");
    };

    # The snippets for each project that are rendered on https://ngi.nixos.org
    projectSnippets = rec {
      one =
        name: project:
        let
          description = optionalString (project.metadata ? summary) ''
            <div class="description">${project.metadata.summary}</div>
          '';
        in
        ''
          <article class="project">
            <div class="row">
              <h2>
                <a href="/project/${name}">${name}</a>
              </h2>
              ${render.deliverableTags.many project}
            </div>
            ${description}
          </article>
        '';
      many = projects: concatLines (mapAttrsToList one projects);
    };

    demoGlue.one = exampleText: ''
      # default.nix
      {
        ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
      }:
      ngipkgs.demo (
        ${toString (intersperse "\n " (splitString "\n" exampleText))}
      )
    '';

    serviceDemo.one =
      services: example:
      let
        demoSystem = import (nixpkgs + "/nixos/lib/eval-config.nix") {
          inherit system;
          modules = (attrValues services) ++ [ example.module ];
        };
        openPorts = demoSystem.config.networking.firewall.allowedTCPPorts;
        # The port that is forwarded to the host so that the user can access the demo service.
        servicePort = (builtins.head openPorts) + 10000;
      in
      ''
        ${heading 2 "demo" "Run a demo deployment locally"}

        <ol>
          <li><strong>Install Nix on your platform.</strong></li>
          <li>
            <strong>Download this Nix file to your computer.</strong>
            It obtains the NGIpkgs source code and declares a basic service configuration
            to be run in a virtual machine.
            ${render.codeSnippet.one {
              filename = "default.nix";
              relative = true;
              downloadable = true;
            }}
          </li>
          <li>
            <strong>Build the virtual machine</strong> defined in <code>default.nix</code> and run it:
            <pre><code>nix-build && ./result</code></pre>
            Building <strong>will</strong> take a while.
          </li>
          <li>
            <strong>Access the service</strong> with a web browser:
            <a href="http://localhost:${toString servicePort}">http://localhost:${toString servicePort}</a>
          </li>
        </ol>
      '';
  };

  # The top-level overview for all projects
  index = ''
    <section class="page-width">
      ${heading 1 null "NGIpkgs"}

      <p>
        NGIpkgs is collection of software applications funded by the <a href="https://www.ngi.eu/ngi-projects/ngi-zero/">Next Generation Internet</a> initiative and packaged for <a href="https://nixos.org">NixOS</a>.
      </p>

      <p>
        This service is still <strong>experimental</strong> and under active development.
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

    ${render.projectSnippets.many projects}

    </section>

    <footer>Version: ${version}, Last Modified: ${lastModified}</footer>
  '';

  # HTML project pages
  projectPages = mapAttrs' (
    name: project:
    nameValuePair "project/${name}" {
      pagetitle = "NGIpkgs | ${name}";
      content = render.projects.one name project;
      summary = project.metadata.summary or null;
      demoFile =
        if project.nixos.examples ? demo then
          (pkgs.writeText "default.nix" (render.demoGlue.one (readFile project.nixos.examples.demo.module)))
        else
          null;
    }
  ) projects;

  # The summary page at the overview root
  indexPage = {
    pagetitle = "NGIpkgs software repository";
    content = index;
    summary = ''
      NGIpkgs is collection of software applications funded by the Next
      Generation Internet initiative and packaged for NixOS. 
    '';
  };

  htmlFile =
    path:
    { ... }@args:
    pkgs.writeText "index.html" ''
      <!DOCTYPE html>
      <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en" dir="ltr">
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
        <title>${args.pagetitle}</title>
        <meta property="og:title" content="${args.pagetitle}" />
        ${optionalString (
          args.summary != null
        ) "<meta property=\"og:description\" content=\"${args.summary}\" />"}
        <meta property="og:url" content="https://ngi.nixos.org/${path}" />
        <meta property="og:type" content="website" />
        <link rel="stylesheet" href="/style.css">
      </head>
      <body>
        ${args.content}
        <script>
          async function copyToClipboard(button, url) {
            let code;
            const firstChild = Array.from(button.children).find(child => child.tagName === "SCRIPT");
            if (firstChild) {
              // JSON is just used for string escaping
              code = JSON.parse(firstChild.textContent);
            } else {
              const response = await fetch(url);
              if (!response.ok) {
                throw new Error("Failed to fetch file: " + response.statusText);
              }
              code = await response.text();
            }
            await navigator.clipboard.writeText(code);
            button.textContent = "Copied ✓";
            setTimeout(() => button.textContent = "Copy", 2000);
          }
        </script>
      </body>
      </html>
    '';

  # Ensure that directories exist and render the jinja2 template that we composed with Nix so far
  writeProjectCommand =
    path: page:
    ''
      mkdir -p "$out/${path}"
    ''
    + optionalString (page.demoFile != null) ''
      cp '${page.demoFile}' "$out/${path}/default.nix"
      chmod +w "$out/${path}/default.nix"
      nixfmt "$out/${path}/default.nix"
    ''
    + ''
      python3 ${./render-template.py} '${htmlFile path page}' "$out/${path}/index.html"
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

  highlightingCss =
    pkgs.runCommand "pygments-css-rules.css" { nativeBuildInputs = [ pkgs.python3Packages.pygments ]; }
      ''
        pygmentize -S default -f html -a .code > $out
      '';

in
pkgs.runCommand "overview"
  {
    nativeBuildInputs = with pkgs; [
      jq
      validator-nu
      (python3.withPackages (
        ps: with ps; [
          jinja2
          markdown-it-py
          pygments
        ]
      ))
      nixfmt-rfc-style
    ];
  }
  (
    ''
      mkdir -pv $out
      cat ${./style.css} ${highlightingCss} > $out/style.css
      ln -s ${fonts} $out/fonts
      python3 ${./render-template.py} '${htmlFile "" indexPage}' "$out/index.html"
    ''
    + (concatLines (mapAttrsToList (path: page: writeProjectCommand path page) projectPages))
    + ''

      vnu -Werror --format json $out/*.html | jq
    ''
  )
