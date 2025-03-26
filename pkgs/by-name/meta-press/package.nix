{
  lib,
  stdenv,
  fetchgit,
  p7zip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "meta-press";
  version = "1.8.17.4";

  src = fetchgit {
    url = "https://framagit.org/Siltaar/meta-press-ext.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sl84E38swbzdlAd6zfm/wwYgzmMwSttri2Gi8Ljcn/k=";
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
