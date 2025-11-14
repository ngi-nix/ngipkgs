{
  callPackage,
  lib,
  python3,
  stdenv,
  texlive,
  version,
  ...
}:
stdenv.mkDerivation {
  name = "NGIpkgs-manuals";
  src =
    with lib.fileset;
    toSource {
      root = ./.;
      fileset = unions [
        (fileFilter (
          file:
          lib.any file.hasExt [
            "md"
            "nix"
          ]
        ) ./.)
        ./Makefile
        ./_ext
        ./_redirects
        ./_static
        ./_templates
        ./conf.py
        ./favicon.png
        ./netlify.toml
        ./robots.txt
      ];
    };
  nativeBuildInputs = [
    python3.pkgs.linkify-it-py
    python3.pkgs.myst-parser
    python3.pkgs.sphinx
    python3.pkgs.sphinx-book-theme
    python3.pkgs.sphinx-copybutton
    python3.pkgs.sphinx-design
    python3.pkgs.sphinx-notfound-page
    python3.pkgs.sphinx-sitemap
    python3.pkgs.pkgs.perl
    # Explanation: generated with nix run github:rgri/tex2nix -- *.tex *.sty
    (callPackage ./tex-env.nix {
      extraTexPackages = {
        inherit (texlive) latexmk gnu-freefont;
      };
    })
  ];
  patchPhase = ''
    substituteInPlace index.md \
      --replace-fail '@NGIPKGS_VERSION@' "${version}"
  '';
  buildPhase = ''
    make html
    make singlehtml
    make latexpdf
  '';
  installPhase = ''
    mkdir -p $out/manual/nix
    cp -R build/html $out/
    cp -R build/singlehtml $out/
    cp build/latex/Nix@NGI.pdf $out/
    cp netlify.toml $out/
  '';
}
