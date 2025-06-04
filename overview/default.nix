# NOTE: run a live overview watcher by executing `devmode`, inside a nix shell
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
    head
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

  eval = module: (lib.evalModules { modules = [ module ]; }).config;
  inherit (lib) mkOption types;

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
          <h${toString i} id="${anchor}">
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
            <template scripted>
              <button class="button copy" onclick="copyToClipboard(this, '${filename}')">
                  ${optionalString (!relative) ''
                    <script type="application/json">
                      ${toJSON (readFile filename)}
                    </script>
                  ''}
                  Copy
              </button>
            </template>
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
            <span class="option-alert" title="This option can't be set by users">Read-only</span>
          '';
          updateScriptStatus =
            let
              optionName = lib.removePrefix "pkgs." option.default.text;
            in
            optionalString (option.type == "package" && !pkgs ? ${optionName}.passthru.updateScript) ''
              <dt>Notes:</dt>
              <dd><span class="option-alert">Missing update script</span> An update script is required for automatically tracking the latest release.</dd>
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
              ${updateScriptStatus}
            </dl>
          </dd>
        '';
      many =
        projectOptions:
        let
          # The length of the attrs path that is common to all options
          # TODO: calculate dynamically
          prefixLength = 2;
          commonPrefix = take prefixLength (head projectOptions).loc;
        in
        optionalString (!empty projectOptions) ''
          ${heading 2 "service" "Options"}
          <details><summary><code>${join "." commonPrefix}</code></summary><dl>
          ${concatLines (map (one prefixLength) projectOptions)}
          </dl></details>
        '';
    };

    examples = rec {
      one = example: ''
        <details><summary>${example.description}</summary>

        ${render.codeSnippet.one { filename = example.module; }}

        </details>
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
        ${render.options.many (pick.options project)}
        ${render.examples.many (pick.examples project)}
        ${optionalString (project.nixos.examples ? demo) (
          render.serviceDemo.one "vm" project.nixos.modules project.nixos.examples.demo
        )}
        ${optionalString (project.nixos.examples ? demo-shell) (
          render.serviceDemo.one "shell" project.nixos.modules project.nixos.examples.demo-shell
        )}
      </article>
    '';

    demoGlue.one = demo-function: exampleText: ''
      # default.nix
      {
        ngipkgs ? import (fetchTarball "https://github.com/ngi-nix/ngipkgs/tarball/main") { },
      }:
      ngipkgs.${demo-function} (
        ${toString (intersperse "\n " (splitString "\n" exampleText))}
      )
    '';

    serviceDemo.one =
      type: modules: example:
      let
        demoSystem = import (nixpkgs + "/nixos/lib/eval-config.nix") {
          inherit system;
          modules =
            [
              example.module
              ./demo/shell.nix
            ]
            ++ (attrValues modules.services)
            ++ (attrValues modules.programs);
        };
        openPorts = demoSystem.config.networking.firewall.allowedTCPPorts;
        # The port that is forwarded to the host so that the user can access the demo service.
        servicePort = if openPorts != [ ] then (builtins.head openPorts) else "";
        nix-config = eval {
          imports = [ ./content-types/nix-config.nix ];
          settings = [
            {
              name = "substituters";
              value = [
                "https://cache.nixos.org/"
                "https://ngi.cachix.org/"
              ];
            }
            {
              name = "trusted-public-keys";
              value = [
                "cache.nixos.org-1:6nchdd59x431o0gwypbmraurkbj16zpmqfgspcdshjy="
                "ngi.cachix.org-1:n+cal72roc3qqulxihpv+tw5t42whxmmhpragkrsrow="
              ];
            }
          ];
        };
      in
      ''
        ${heading 2 "demo" (
          if type == "shell" then "Try the program in a shell" else "Try the service in a VM"
        )}

        <ol>
          <li>
            <strong>Install Nix</strong>
              <ul>
                <li>Arch Linux</li>
                  <pre><code>pacman --sync --refresh --noconfirm curl git jq nix</code></pre>
                <li>Debian/Ubuntu</li>
                  <pre><code>apt install --yes curl git jq nix</code></pre>
              </ul>
          </li>
          <li>
            <strong>Download a configuration file</strong>
              ${render.codeSnippet.one {
                filename = "default.nix";
                relative = true;
                downloadable = true;
              }}
          </li>
          <li>
            <strong>Enable binary substituters</strong>
              <pre><code>${nix-config}</code></pre>
              <pre><code>export NIX_CONFIG</code></pre>
          </li>
          <li>
            <strong>Build and run a virtual machine</strong>
              <ul>
                <li>Arch Linux, Debian Sid and Ubuntu 25.04</li>
                  <pre><code>nix-build ./default.nix && ./result</code></pre>
                <li>Debian 12 and Ubuntu 24.04/24.10</li>
                  <pre><code>rev=$(nix-instantiate --eval --attr sources.nixpkgs.rev https://github.com/ngi-nix/ngipkgs/archive/master.tar.gz | jq --raw-output)</code></pre>
                  <pre><code>nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/$rev.tar.gz --packages nix --run "nix-build ./default.nix && ./result"</code></pre>
              </ul>
          </li>
          ${
            if servicePort != "" then
              ''
                <li>
                  <strong>Access the service</strong><br />
                    Open a web browser at <a href="http://localhost:${toString servicePort}">http://localhost:${toString servicePort}</a> .
                </li>
              ''
            else
              ""
          }
        </ol>
      '';
  };

  # HTML project pages
  projectPages = mapAttrs' (
    name: project:
    nameValuePair "project/${name}" {
      pagetitle = "NGIpkgs | ${name}";
      content = render.projects.one name project;
      summary = project.metadata.summary or null;
      demoFile =
        if project.nixos.examples ? demo then
          (pkgs.writeText "default.nix" (
            render.demoGlue.one "demo-vm" (readFile project.nixos.examples.demo.module)
          ))
        else if project.nixos.examples ? demo-shell then
          (pkgs.writeText "default.nix" (
            render.demoGlue.one "demo-shell" (readFile project.nixos.examples.demo-shell.module)
          ))
        else
          null;
    }
  ) projects;

  index = eval {
    imports = [ ./content-types/project-list.nix ];

    projects = lib.mapAttrsToList (name: project: {
      inherit name;
      description = project.metadata.summary or null;
      deliverables = {
        service = project.nixos.modules ? services && project.nixos.modules.services != { };
        program = project.nixos.modules ? programs && project.nixos.modules.programs != { };
        demo = project.nixos.examples ? demo || project.nixos.examples ? demo-shell;
      };
    }) projects;
    inherit version;
    inherit lastModified;
  };

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
          // On document load, put all elements into the DOM that can be used with JS only
          document.addEventListener("DOMContentLoaded", () => {
            document.querySelectorAll("template[scripted]").forEach(template => {
                const content = template.content;
                template.replaceWith(content);
              });
          });

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
