{
  callPackage,
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
      pythonPackages = python3.withPackages (
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
