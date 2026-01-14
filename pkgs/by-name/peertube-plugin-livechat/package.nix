{
  lib,
  buildNpmPackage,
  fetchNpmDeps,
  fetchFromGitHub,
  runCommand,
  prosody,
  nodejs_22,
}:
let
  details = {
    livechat = rec {
      pname = "peertube-plugin-livechat";
      version = "14.0.2";
      src = fetchFromGitHub {
        owner = "JohnXLivingston";
        repo = "peertube-plugin-livechat";
        rev = "refs/tags/v${version}";
        hash = "sha256-3lb0W/x5yuybxkev8vXgBej3WdqB0OeF++G+i1co9gQ=";
      };
      npmDeps = fetchNpmDeps {
        name = "${pname}-${version}-deps";
        inherit src;
        hash = "sha256-pumyBnl8KlvQsrTuComluc6dO0RSe9k7kOBEBwFjzPQ=";
      };
    };

    # Check <livechat-src>/conversejs/build-conversejs.sh for which conversejs to use
    conversejs = rec {
      pname = "conversejs-livechat";
      version = "12.0.1";
      src = fetchFromGitHub {
        owner = "JohnXLivingston";
        repo = "converse.js";
        rev = "refs/tags/livechat-${version}";
        hash = "sha256-vD5ZFeGZYcsDX/Ye0tmBlRveOGusLP2NGkvHcNdZyqE=";
      };
      npmDeps = fetchNpmDeps {
        name = "${pname}-${version}-deps";
        inherit src;
        hash = "sha256-jTs+1fLPE6D78rHhudEc+qVTyA2E8Z7C1CgKfdl1w8o=";
      };
    };
  };

  commonMeta = {
    description = "Provides chat system for Peertube videos";
    homepage = "https://github.com/JohnXLivingston/peertube-plugin-livechat";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.unix;
  };

  # converse.js building needs generated translations from livechat
  translations = buildNpmPackage {
    pname = "${details.livechat.pname}-translations";
    inherit (details.livechat) version src npmDeps;

    dontConfigure = true;

    npmBuildScript = "build:languages";

    installPhase = ''
      runHook preInstall

      mv dist/languages $out

      runHook postInstall
    '';

    meta = {
      description = "${commonMeta.description} - generated translations";
      inherit (commonMeta)
        homepage
        license
        maintainers
        platforms
        ;
    };
  };

  # converse.js src is expected to be downloaded here by various scripts
  merged-src =
    runCommand "${details.livechat.pname}-src-full"
      {
        meta = {
          description = "${commonMeta.description} - source with converse.js merged in";
          platforms = lib.platforms.all;
          inherit (commonMeta) homepage license maintainers;
        };
      }
      ''
        cp -r --no-preserve=mode,ownership ${details.livechat.src} $out
        mkdir -p $out/vendor
        cp -r --no-preserve=mode,ownership ${details.conversejs.src} $out/vendor/${details.conversejs.pname}-${details.conversejs.version}
      '';

  # <livechat-src>/conversejs/build-conversejs.sh applies various patches to the converse.js source before attempting to build it
  # Patch the script to only applies its patches, then return the new source for separate converse.js building
  merged-patched-src = buildNpmPackage {
    pname = "${details.conversejs.pname}-src-patched";
    inherit (details.conversejs) version;
    inherit (details.livechat) npmDeps;

    src = merged-src;

    postPatch = ''
      substituteInPlace conversejs/build-conversejs.sh \
        --replace-fail '/usr/bin/env node' 'node' \
        --replace-fail 'if [[ ! -d "$converse_build_dir/node_modules" ]]; then' 'echo "Done patching ConverseJS" && exit 0; if [[ ! -d "$converse_build_dir/node_modules" ]]; then'
    '';

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bash conversejs/build-conversejs.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      rm -r node_modules
      rm -r vendor/${details.conversejs.pname}-${details.conversejs.version}
      mv build/conversejs vendor/${details.conversejs.pname}-${details.conversejs.version}
      rmdir build

      cp -r . $out

      runHook postInstall
    '';

    meta = {
      description = "${commonMeta.description} - source with merged converse.js patched";
      inherit (commonMeta)
        homepage
        license
        maintainers
        platforms
        ;
    };
  };

  # livechat needs converse.js
  conversejs = buildNpmPackage {
    inherit (details.conversejs) pname version npmDeps;

    src = merged-patched-src;

    postPatch = ''
      substituteInPlace conversejs/build-conversejs.sh \
        --replace-fail 'converse_build_dir="$rootdir/build/conversejs"' 'converse_build_dir="$converse_src_dir"' \
        --replace-fail 'if cmp -s "$converse_src_dir/package.json" "$converse_build_dir/package.json"' 'echo "Skipping re-modifying of source..."; if false; then if cmp -s "$converse_src_dir/package.json" "$converse_build_dir/package.json"' \
        --replace-fail 'if [[ ! -d "$converse_build_dir/node_modules" ]]; then' 'fi; if [[ ! -d "$converse_build_dir/node_modules" ]]; then'
    '';

    npmRoot = "vendor/${details.conversejs.pname}-${details.conversejs.version}";

    makeCacheWritable = true;

    # See <https://github.com/NixOS/nixpkgs/issues/474535>.
    nodejs = nodejs_22;

    buildPhase = ''
      runHook preBuild

      # Translations are needed for webpack building, else it silently fails
      mkdir dist
      cp -r --no-preserve=mode,ownership ${translations} dist/languages

      bash conversejs/build-conversejs.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/client
      cp -r dist/client/conversejs $out/client/
      cp dist/converse-emoji.json $out/

      runHook postInstall
    '';

    doInstallCheck = true;

    installCheckPhase = ''
      runHook preInstallCheck

      if [ ! -f $out/client/conversejs/converse.min.js -o ! -f $out/client/conversejs/converse.min.css ]; then
        echo "converse.min.js or converse.min.css failed to be generated, please check the build log!"
        exit 1
      fi

      runHook postInstallCheck
    '';

    meta = {
      description = "Web-based XMPP/Jabber chat client written in JavaScript";
      homepage = "https://conversejs.org";
      license = lib.licenses.mpl20;
      inherit (commonMeta) maintainers platforms;
    };
  };

  livechatProsody = prosody.override {
    withExtraLuaPackages = (
      p: [
        # Needed by one of peertube-livechat's prosody modules
        p.lrexlib-oniguruma
      ]
    );
  };
in
buildNpmPackage {
  inherit (details.livechat) pname version npmDeps;

  src = merged-src;

  patches = [
    # Change default, we don't want to bother with downloading & including a bundled prosody AppImage
    ./9000-Default-to-using-system-installed-prosody.patch
  ];

  postPatch = ''
    mkdir -p dist/client
    cp -r --no-preserve=mode,ownership ${translations} dist/languages
    cp -r --no-preserve=mode,ownership ${conversejs}/* dist/

    # Don't try to delete & rebuild everything when installing (either in this derivation or as a plugin in peertube)
    # clean:light would get rid of the built conversejs
    # build:languages & conversejs already built separately, build:prosody would try to download an AppImage
    substituteInPlace package.json \
      --replace-fail '"prepare": "npm run clean && npm run build",' "" \
      --replace-fail '"build:avatars": "./build-avatars.js"' '"build:avatars": "node ./build-avatars.js"' \
      --replace-fail '"build": "npm-run-all -s clean:light build:languages' '"build": "npm-run-all -s' \
      --replace-fail 'build:prosodymodules build:converse build:prosody' 'build:prosodymodules'

    # Wants to run its own prosody instance
    substituteInPlace server/lib/prosody/config.ts \
      --replace-fail "exec = 'prosody'" "exec = '${lib.getExe' livechatProsody "prosody"}'" \
      --replace-fail "execCtl = 'prosodyctl'" "execCtl = '${lib.getExe' livechatProsody "prosodyctl"}'" \
  '';

  meta = {
    inherit (commonMeta)
      description
      homepage
      license
      maintainers
      platforms
      ;
  };
}
