{
  lib,
  stdenv,
  fetchgit,
  p7zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "meta-press";
  version = "1.8.17.1";

  src = fetchgit {
    url = "https://framagit.org/Siltaar/meta-press-ext.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5/TotS+Je4AlKVPq1H4BVEc2gkJ8NSmDuKJzRN7qR1M=";
  };

  # The Makefile moves the output to the enclosing folder
  preUnpack = ''
    mkdir build
    cd build
  '';

  nativeBuildInputs = [p7zip];

  makeFlags = ["BUNDLE_NAME=firefox_addon"];

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
