{
  fetchgit,
  lib,
  php,
  nixosTests,
}:
php.buildComposerProject (finalAttrs: {
  pname = "kbin";
  version = "0.0.1";

  src = fetchgit {
    url = "https://codeberg.org/Kbin/kbin-core/";
    rev = "cc727b9133b60fe7411b8c4dbd90c0319d225916";
    hash = "sha256-qq05NGAFUa+Qki9rx5Th/ry6B+dowzbTc35YP7gkoAY=";

    postFetch = ''
      substituteInPlace $out/package.json \
        --replace '"devDependencies": {' '"name": "${finalAttrs.pname}-frontend", "devDependencies": {' \
        --replace 'UNLICENSED' 'AGPL-3.0-or-later' \
        --replace 'encore' 'echo $PATH; set -x; encore'

      substituteInPlace $out/yarn.lock \
        --replace '@symfony/stimulus-bundle' '_symfony/stimulus-bundle' \
        --replace '@symfony/ux-autocomplete' '_symfony/ux-autocomplete' \
        --replace '@symfony/ux-chartjs'      '_symfony/ux-chartjs'
    '';
  };

  preConfigure = ''
    cp .env.example .env
  '';

  composerNoPlugins = false;
  php = php.withExtensions ({
    enabled,
    all,
  }:
    enabled ++ [all.amqp all.redis]);
  vendorHash = "sha256-lv13ze8PlJyOMDIrXrPzvQr4AgDpYx8Ns9+lUEFUEJ4=";

  passthru.tests.kbin = nixosTests.kbin;
})
