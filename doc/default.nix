{
  lib,
  path,
  version,
  revision,
  runCommand,
  writeShellScriptBin,
  roboto,
  devmode,
  nixos-render-docs-redirects,
  documentation-highlighter,
  buildPackages,
  checkRedirects ? true,
  ...
}:
let
  common = import ./common.nix;
  manpageUrls = path + "/doc/manpage-urls.json";

  prepareManualFromMD = file: ''
    cp -r --no-preserve=all $inputs/* .

    substituteInPlace ${file} \
      --replace-fail '@NGIPKGS_VERSION@' "${version}"
  '';

in

{
  manualHTML =
    runCommand "ngipkgs-manual-html"
      {
        allowedReferences = [ "out" ];
        inputs = lib.sourceFilesBySuffices ./. [ ".md" ];
        meta.description = "The NGIpkgs manual in HTML format";
        nativeBuildInputs = [ buildPackages.nixos-render-docs ];
      }
      ''
        # Generate the HTML manual.
        dst=$out/${common.outputPath}
        mkdir -p $dst

        cp ${path}/doc/style.css $dst/style.css
        cp ${path}/doc/anchor.min.js $dst/anchor.min.js
        cp ${path}/doc/anchor-use.js $dst/anchor-use.js

        cp -r ${documentation-highlighter} $dst/highlightjs

        ${prepareManualFromMD "Manual.md"}

        nixos-render-docs -j $NIX_BUILD_CORES manual html \
          --manpage-urls ${manpageUrls} \
          ${if checkRedirects then "--redirects ${./redirects.json}" else ""} \
          --revision ${lib.escapeShellArg revision} \
          --generator "nixos-render-docs ${lib.version}" \
          --stylesheet style.css \
          --stylesheet highlightjs/mono-blue.css \
          --script ./highlightjs/highlight.pack.js \
          --script ./highlightjs/loader.js \
          --script ./anchor.min.js \
          --script ./anchor-use.js \
          --toc-depth 1 \
          --chunk-toc-depth 1 \
          ./Manual.md \
          $dst/${common.indexPath}

        cp ${roboto.src}/web/Roboto\[ital\,wdth\,wght\].ttf "$dst/Roboto.ttf"

        mkdir -p $out/nix-support
        echo "nix-build out $out" >> $out/nix-support/hydra-build-products
        echo "doc manual $dst" >> $out/nix-support/hydra-build-products
      '';

  shell = {
    packages = {
      devmode =
        (devmode.override {
          buildArgs = ''${toString ../default.nix} -A doc.manualHTML'';
          open = "/${common.outputPath}/${common.indexPath}";
        }).overrideAttrs
          (previousAttrs: {
            # Explanation: the `devmode` executable name is already used for the `overview`.
            buildCommand = previousAttrs.buildCommand + ''
              mv $out/bin/devmode $out/bin/doc-devmode
            '';
          });

      redirects = writeShellScriptBin "doc-redirects" ''
        ${lib.getExe nixos-render-docs-redirects} --file ${toString ./redirects.json} "$@"
      '';
    };
  };
}
