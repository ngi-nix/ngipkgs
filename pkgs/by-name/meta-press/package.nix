{
  lib,
  stdenv,
  fetchFromGitLab,
  p7zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "meta-press";
  version = "1.9.1";

  src = fetchFromGitLab {
    domain = "framagit.org";
    owner = "Siltaar";
    repo = "meta-press-ext";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TRda285BUEWyIMnKAxaPpWw682I3nrl3yGetXQcu5z8=";
  };

  # The Makefile moves the output to the enclosing folder
  preUnpack = ''
    mkdir build
    cd build
  '';

  nativeBuildInputs = [ p7zip ];

  makeFlags = [ "BUNDLE_NAME=firefox_addon" ];

  # An xpi is just a renamed zip for firefox extensions
  installPhase = ''
    runHook preInstall

    install -Dm644 ../firefox_addon.zip $out/firefox_addon.xpi

    runHook postInstall
  '';

  meta = {
    description = "Decentralized search engine & automatized press reviews";
    homepage = "https://www.meta-press.es";
    license = with lib.licenses; [
      mit
      gpl3Only
    ];
    platforms = lib.platforms.linux;
  };
})
