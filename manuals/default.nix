{
  callPackage,
  fetchFromGitHub,
  fetchurl,
  gnused,
  imagemagick,
  installShellFiles,
  lib,
  perl,
  python3,
  revision,
  stdenv,
  texinfo,
  version,
  ...
}:
let
  python = python3.override {
    packageOverrides = final: prev: {
      # nixpkgs PR https://github.com/NixOS/nixpkgs/pull/504645
      sphinx-last-updated-by-git = prev.sphinx-last-updated-by-git.overridePythonAttrs {
        version = "0.3.8-unstable-2026-03-22";
        src = fetchFromGitHub {
          owner = "mgeier";
          repo = "sphinx-last-updated-by-git";
          rev = "8d4eef2561996319e6f785b4faa914a1e6545476";
          hash = "sha256-30pZiqWs6Da+O8j08EIHrUoiJfJUPT6FdDiPBjmvRL8=";
          fetchSubmodules = true;
          leaveDotGit = true;
        };
      };
    };
  };

  options = callPackage ./Options.nix { };

  common = stdenv.mkDerivation (finalAttrs: {
    pname = "NGIpkgs-Manuals-${finalAttrs.passthru.format}";
    inherit version;
    src =
      with lib.fileset;
      toSource {
        root = ../.;
        fileset = intersection (gitTracked ../.) (unions [
          (fileFilter (
            file:
            lib.any file.hasExt [
              "md"
              "nix"
            ]
          ) ../.)
          ./Makefile
          ./_redirects
          ./_static
          ./_templates
          ./conf.py
          ./netlify.toml
          ./robots.txt
          ../projects
        ]);
      };

    nativeBuildInputs = [
      finalAttrs.passthru.pythonPackages
      gnused
      imagemagick
      perl
    ];

    patchPhase = ''
      runHook prePatch
      mkdir -p manuals/Options
      ln -sf ${options.optionsMyST} manuals/Options/generated.md

      for manual in ${lib.concatStringsSep " " finalAttrs.passthru.manuals}; do
        substituteInPlace manuals/''${manual}.md \
          --replace-fail '@NGIPKGS_REVISION@' "${revision}" \
          --replace-fail '@NGIPKGS_VERSION@' "${version}"
      done

      mkdir -p manuals/_static/_img
      ln -s ${finalAttrs.passthru.logos.ngi.png} manuals/_static/_img/ngi.png
      ln -s ${finalAttrs.passthru.logos.nix.svg} manuals/_static/_img/nix.svg
      magick ${finalAttrs.passthru.logos.nix.svg} \
        -background transparent \
        -define icon:auto-resize=32 \
        -extent "%[fx:max(w,h)]x%[fx:max(w,h)]" \
        -fuzz 10% \
        -gravity center \
        -transparent white \
        -trim +repage \
        manuals/favicon.ico
      runHook postPatch
    '';

    buildPhase = ''
      runHook preBuild
      make -C manuals ${finalAttrs.passthru.format}
      runHook postBuild
    '';

    passthru = {
      inherit options;
      manuals = [
        "Contributor"
        "Options"
        "User"
      ];
      logos = {
        nix.svg = fetchurl {
          url = "https://brand.nixos.org/logos/nixos-logomark-default-gradient-minimal.svg";
          hash = "sha256-YrOle9qo0G92vvCjy9FAkyNOdyAz1DR+xoc+/CpK0yk=";
        };
        ngi.png = fetchurl {
          url = "https://ngi.eu/wp-content/uploads/sites/77/2019/06/Logo-NGI_Explicit-with-baseline-rgb.png";
          hash = "sha256-m5f2WVVj1b7dyxBle/Ug959DAJ7PYinK0OlkD/zxh0s=";
        };
      };
      pythonPackages = python.withPackages (
        pyPkgs: with pyPkgs; [
          linkify-it-py
          myst-parser
          sphinx
          sphinx-book-theme
          sphinx-copybutton
          sphinx-design
          sphinx-notfound-page
          sphinx-sitemap
        ]
      );
    };
  });

in

# Split the different formats
# in different derivations instead of different outputs
# in order to only use `nix build -f. manuals.man`
# as a `.git/hooks/pre-push` check.
lib.recurseIntoAttrs {
  html = common.overrideAttrs (
    finalAttrs: previousAttrs: {
      installPhase = ''
        runHook preInstall
        cp -R manuals/build/html $out/
        cp -t $out \
          manuals/netlify.toml \
          manuals/robots.txt
        runHook postInstall
      '';
      passthru = previousAttrs.passthru or { } // {
        format = "html";
      };
    }
  );

  info = common.overrideAttrs (previousAttrs: {
    passthru = previousAttrs.passthru or { } // {
      format = "info";
    };
    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [ texinfo ];
    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/info
      cp manuals/build/texinfo/*.info $out/share/info/
      runHook postInstall
    '';
  });

  man = common.overrideAttrs (previousAttrs: {
    passthru = previousAttrs.passthru or { } // {
      format = "man";
    };
    nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [ installShellFiles ];
    installPhase = ''
      runHook preInstall
      installManPage manuals/build/man/*.5
      runHook postInstall
    '';
  });
}
