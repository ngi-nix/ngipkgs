{
  stdenv,
  bashNonInteractive,
  dpkg,
  fpm,
  bbb-shared-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bbb-config";
  version = bbb-shared-utils.versionComponent;

  inherit (bbb-shared-utils) src postPatch;

  strictDeps = true;

  nativeBuildInputs = [
    dpkg
    fpm
  ];

  buildInputs = [
    bashNonInteractive
  ];

  buildPhase = ''
    runHook preBuild
    env LOCAL_BUILD=1 build/setup-inside-docker.sh bbb-config
    runHook postBuild
  '';

  # FIXME Missing dependencies of installed scripts
  installPhase = ''
    runHook preInstall
    dpkg -x artifacts/*.deb $out
    # Fix up Debian-isms
    # No usr please, we have the prefix for that
    mv -vt $out/ $out/usr/*
    rmdir $out/usr
    # Add Nix-isms
    runHook postInstall
  '';

  meta = bbb-shared-utils.meta // {
    description = bbb-shared-utils.meta.description + " (bbb-config)";
  };
})
