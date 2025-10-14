{
  lib,
  php82,
  fetchFromGitHub,
  fetchgit,
  moreutils,
  yq,
  unstableGitUpdater,
  writeShellScript,

  withS3 ? false,
}:
let
  inherit (lib)
    optionalString
    ;

  php = php82.override {
    packageOverrides = final: prev: {
      extensions = prev.extensions // {
        # newer versions don't seem to work with kbin
        redis = prev.extensions.redis.overrideAttrs (
          finalAttrs: previousAttrs: {
            version = "6.0.2";
            src = fetchFromGitHub {
              repo = "phpredis";
              owner = "phpredis";
              rev = finalAttrs.version;
              hash = "sha256-Ie31zak6Rqxm2+jGXWg6KN4czHe9e+190jZRQ5VoB+M=";
            };
          }
        );
      };
    };
  };
in
# NOTE: when updating this:
# - also update the `kbin-frontend` yarn deps hash and its `package.json`
php.buildComposerProject (
  finalAttrs:
  let
    pname = "kbin";
    baseVersion = "0.0.1";
    version = "0.0.1-unstable-2024-02-05";
  in
  {
    inherit pname version;

    src = fetchgit {
      url = "https://codeberg.org/Kbin/kbin-core/";
      rev = "0c0cb1a800f9c36f8fdf50ea1935192863ca11b0";
      hash = "sha256-g8/w2jYsYfbTqtgtEBvTbD6qYKbGBGG1ABPulHm4Kho=";
      postFetch = ''
        # Work around <https://github.com/NixOS/nixpkgs/pull/257337>.
        substituteInPlace $out/yarn.lock \
          --replace-fail '@symfony/stimulus-bundle'   '_symfony/stimulus-bundle' \
          --replace-fail '@symfony/ux-autocomplete'   '_symfony/ux-autocomplete' \
          --replace-fail '@symfony/ux-chartjs'        '_symfony/ux-chartjs' \
          --replace-fail '@symfony/ux-live-component' '_symfony/ux-live-component' \
          --replace-fail '@symfony/ux-turbo'          '_symfony/ux-turbo'

        substituteInPlace $out/composer.lock \
          --replace-fail 'nucleos/NucleosAntiSpamBundle' 'matgrula/NucleosAntiSpamBundle'
      '';
    };

    vendorHash = "sha256-lnyvcOCsTruLD2OzrwIqSqtXTKswKpoLFdwip4MpNM4=";

    composerNoPlugins = false;
    composerStrictValidation = false;
    doInstallCheck = false;

    nativeBuildInputs = [
      moreutils
      yq
    ];

    php = php.withExtensions (
      {
        enabled,
        all,
      }:
      enabled
      ++ (with all; [
        amqp
        redis
      ])
    );

    postPatch = ''
      # .env file must be used, because it is used to set the default values
      cp .env.example .env

      yq '.oneup_flysystem.adapters.default_adapter.local.location = "/var/lib/kbin/media"' \
        < config/packages/oneup_flysystem.yaml \
        | sponge config/packages/oneup_flysystem.yaml
    ''
    + (optionalString withS3 ''
      yq '(
        .oneup_flysystem.filesystems.public_uploads_filesystem.adapter = "kbin.s3_adapter" |
        .oneup_flysystem.adapters.kbin.s3_adapter.awss3v3 = {client: "kbin.s3_client", bucket: "%amazon.s3.bucket%"}
      )' \
        < config/packages/oneup_flysystem.yaml \
        | sponge config/packages/oneup_flysystem.yaml
    '');

    preBuild = ''
      # composer does not support unstable versioning scheme
      export version="${baseVersion}"
    '';

    installCheckPhase = ''
      runHook preInstallCheck

      export DATABASE_URL="sqlite:///test.db"
      php bin/console doctrine:database:create
      php bin/console doctrine:migrations:migrate
      SYMFONY_DEPRECATIONS_HELPER=disabled php bin/phpunit --testdox tests/Functional

      runHook postInstallCheck
    '';

    passthru = {
      inherit withS3;
      inherit (finalAttrs) php;
      updateScript = unstableGitUpdater {
        tagConverter = writeShellScript "${pname}-tag-converter.sh" ''
          read -r input_tag
          if [ "$input_tag" = 0 ]
          then
            printf '%s' ${baseVersion}
          else
            printf '%s' "$input_tag"
          fi
        '';
      };
    };
  }
)
