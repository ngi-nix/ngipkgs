{
  fetchgit,
  lib,
  php,
  nixosTests,
}:
let 
  phpWithExtensions = php.withExtensions (
    { enabled, all }:
      enabled ++ [all.amqp all.redis]
  );
in
phpWithExtensions.buildComposerProject (finalAttrs: let
  pname = "kbin";
  version = "0.0.1";
in {
  inherit pname version;

  src = fetchgit {
    url = "https://codeberg.org/Kbin/kbin-core/";
    rev = "cc727b9133b60fe7411b8c4dbd90c0319d225916";
    hash = "sha256-7PjIKtPiivMCCSPvV0OOoGZ7eCxvcRFM/2iZhzC7dF4=";

    postFetch = ''
      substituteInPlace $out/package.json \
        --replace '"devDependencies": {' '"name": "${pname}-frontend", "version": "${version}", "devDependencies": {' \
        --replace 'UNLICENSED' 'AGPL-3.0-or-later'

       substituteInPlace $out/yarn.lock \
         --replace '@symfony/stimulus-bundle' '_symfony/stimulus-bundle' \
         --replace '@symfony/ux-autocomplete' '_symfony/ux-autocomplete' \
         --replace '@symfony/ux-chartjs'      '_symfony/ux-chartjs'
    '';
  };

  vendorHash = "sha256-lv13ze8PlJyOMDIrXrPzvQr4AgDpYx8Ns9+lUEFUEJ4=";

  preConfigure = "touch .env";

  composerNoPlugins = false;

  passthru = {
    php = phpWithExtensions;
    tests.kbin = nixosTests.kbin;
  };
})
