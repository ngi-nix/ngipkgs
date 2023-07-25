{ lib
, stdenv
, fetchFromGitHub
, php
, pkgs
, nixosTests
, dataDir ? "/var/lib/flarum"
, runtimeDir ? "/run/flarum"
}:

let
  pname = "flarum";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "albertchae";
    repo = pname;
    rev = "833ccafb14cbf196c92d23524d4026bc8c740441";
    hash = "sha256-3Ig20CgjAaJq4dkSrtkjV6yqDpiaBv7Tcc81wUwCfVQ=";
  };
  package = (import ./composition.nix {
    inherit pkgs;
    inherit (stdenv.hostPlatform) system;
    noDev = true; # Disable development dependencies
  }).overrideAttrs (attrs : {
    installPhase = attrs.installPhase + ''
      cp -ar ${src}/{site.php,flarum,.nginx.conf} $out/
      # ln -s $\{dependencies}/composer.{json,lock} $out/
      # ln -s $\{dependencies}/vendor $out/
      cp ${src}/public/index.php $out/public/
      # ln -s $\{cfg.stateDir}/assets $out/public/assets
      # ln -s $\{cfg.stateDir}/{storage,extensions} $out/
    '';
  });
in package.override rec {
  inherit src version pname;

  passthru = {
    tests = { inherit (nixosTests) pixelfed; };
    updateScript = ./update.sh;
  };

  meta = with lib; {
    description = "A federated image sharing platform";
    license = licenses.agpl3Only;
    homepage = "https://pixelfed.org/";
    maintainers = with maintainers; [ raitobezarius ];
    platforms = php.meta.platforms;
  };
}
