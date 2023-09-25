{
  fetchgit,
  lib,
  php,
}:
php.buildComposerProject (finalAttrs: {
  pname = "kbin";
  version = "0.0.1";

  src = fetchgit {
    url = "https://codeberg.org/Kbin/kbin-core/";
    rev = "cc727b9133b60fe7411b8c4dbd90c0319d225916";
    hash = "sha256-oBJ6JNxTJxXabmEBHIRWGYUuAN2Es32S35+QNbIi1SY=";
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
})
