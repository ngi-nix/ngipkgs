# NOTE: run a live overview watcher by executing `devmode`, inside a nix shell
{
  lib,
  options,
  pkgs,
  projects,
  self,
}:
let
  inherit (builtins)
    any
    attrValues
    filter
    isList
    isInt
    substring
    toString
    ;

  eval = module: (lib.evalModules { modules = [ module ]; }).config;

  inherit (lib)
    concatLines
    mapAttrsToList
    optionalString
    filterAttrs
    mapAttrs'
    nameValuePair
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
    options = prefix: filter (option: lib.lists.hasPrefix prefix option.loc) (attrValues options);
    examples =
      project:
      attrValues (
        filterAttrs (name: example: example.module != null) (
          project.nixos.examples
          // (lib.filter-map project.nixos.modules.programs "examples")
          // (lib.filter-map project.nixos.modules.services "examples")
        )
      );
  };

  render = {
    options =
      prefix: project:
      eval {
        imports = [ ./content-types/option-list.nix ];
        _module.args.pkgs = pkgs;

        inherit prefix;
        module = lib.attrByPath (prefix ++ [ "module" ]) null project.nixos.modules;
        project-options = map (option: {
          inherit (option)
            type
            description
            readOnly
            ;
          attrpath = option.loc;
          default = option.default or { };
        }) (pick.options prefix);
      };

    # The indivdual page of a project
    projects.one =
      name: project:
      let
        breadcrumbs = ''
          <nav aria-label="Breadcrumb" class="breadcrumb">
            <ol>
              <li><a href="/">Projects</a></li>
              <li>${name}</li>
            </ol>
          </nav>
        '';

        metadata-summary = optionalString (project.metadata != null && project.metadata.summary != null) ''
          <p>
            ${project.metadata.summary}
          </p>
        '';

        demo-instructions =
          if (project.nixos.demo == null) then
            ''
              ${heading 2 "demo" "Demo"}
              <a href="https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md">Implement missing demo</a>
            ''
          else
            (lib.concatMapAttrsStringSep "\n" (
              type: demo: toString (render.serviceDemo.one type demo)
            ) project.nixos.demo);

        # TODO: clean up
        optionsRender =
          lib.concatMapStringsSep "\n"
            (
              type:
              lib.concatMapAttrsStringSep "\n" (
                name: val:
                let
                  attrpath-prefix = [
                    type
                    name
                  ];
                in
                render.options attrpath-prefix project
              ) project.nixos.modules.${type}
            )
            [
              "programs"
              "services"
            ];

        examples = eval {
          imports = [ ./content-types/example-list.nix ];
          examples = map (value: {
            inherit (value)
              description
              module
              name
              tests
              ;
          }) (pick.examples project);
        };

        metadata-subgrants = eval {
          imports = [ ./content-types/metadata-subgrants.nix ];
          subgrants = project.metadata.subgrants or null;
        };

        metadata-links = eval {
          imports = [ ./content-types/metadata-links.nix ];
          links = project.metadata.links or null;
        };

      in
      ''
        <article class="page-width">
          ${breadcrumbs}
          ${heading 1 null name}
          ${metadata-summary}
          ${demo-instructions}
          ${optionalString (lib.trim optionsRender != "") "${heading 2 "service" "Options"}"}
          ${optionsRender}
          ${examples}
          ${metadata-subgrants}
          ${metadata-links}
        </article>
      '';

    serviceDemo.one =
      type: demo:
      eval {
        imports = [ ./content-types/demo-instructions.nix ];
        _module.args.pkgs = pkgs;

        heading = heading 2 "demo" (
          if type == "shell" then "Try the program in a shell" else "Try the service in a VM"
        );

        demo = {
          inherit type;
          inherit (demo)
            module
            tests
            problem
            description
            usage-instructions
            ;
          _module.args.pkgs = pkgs;
        };
      };
  };

  # HTML project pages
  projectPages = mapAttrs' (
    name: project:
    nameValuePair "project/${name}" {
      pagetitle = "NGIpkgs | ${name}";
      content = render.projects.one name project;
      summary = project.metadata.summary or null;
      # needed for downloading demo code blocks
      demoFile =
        let
          demo = project.nixos.demo;
          mkDemoFile =
            type: demo:
            (eval {
              imports = [ ./content-types/demo.nix ];
              inherit type;
              inherit (demo)
                tests
                module
                description
                problem
                ;
              _module.args.pkgs = pkgs;
            }).filepath;
        in
        if demo != null then lib.concatMapAttrs mkDemoFile demo else null;
    }
  ) projects;

  index = eval {
    imports = [ ./content-types/project-list.nix ];

    projects = lib.mapAttrsToList (name: project: {
      inherit name;
      description = project.metadata.summary or null;
      deliverables =
        (lib.mapAttrsToList (name: value: {
          inherit name;
          type = "program";
          hasProblem = value.module == null;
        }) project.nixos.modules.programs)
        ++ (lib.mapAttrsToList (name: value: {
          inherit name;
          type = "service";
          hasProblem = value.module == null;
        }) project.nixos.modules.services)
        ++ [
          {
            name = project.name;
            type = "demo";
            hasProblem =
              project.nixos.demo == null
              || lib.any (demo: demo.module == null || demo.problem != null) (attrValues project.nixos.demo);
          }
        ];
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

          ${
            "" # TODO: this should be the exact same code for copying file content
          }
          async function copyInlineToClipboard(button) {
            const scriptElement = Array.from(button.children).find(child => child.tagName === "SCRIPT");
            const label = button.querySelector('.copy-label');
            if (scriptElement && label) {
              const code = JSON.parse(scriptElement.textContent);
              await navigator.clipboard.writeText(code);
              label.textContent = "Copied ✓";
              setTimeout(() => label.textContent = "Copy", 2000);
            }
          }

          // Automatically open target element on page load
          function openTarget() {
            var hash = location.hash.substring(1);
            if(hash) var details = document.getElementById(hash);
            if(details && details.tagName.toLowerCase() === 'details') details.open = true;
          }
          window.addEventListener('load', openTarget);
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
      cp '${page.demoFile}' "$out/${path}/${page.demoFile.name}"
      chmod +w "$out/${path}/${page.demoFile.name}"
      nixfmt "$out/${path}/${page.demoFile.name}"
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
