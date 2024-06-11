{
  lib,
  buildNpmPackage,
  fetchNpmDeps,
  fetchFromGitHub,
  fetchpatch,
  stdenvNoCC,
  symlinkJoin,
  nodePackages,
  npmHooks,
  prosody,
}:

let
  livechat-pname = "peertube-plugin-livechat";
  livechat-version = "10.0.2";
  livechat-src = fetchFromGitHub {
    owner = "JohnXLivingston";
    repo = "peertube-plugin-livechat";
    rev = "refs/tags/v${livechat-version}";
    hash = "sha256-NnhH69yWyB1gZWKtp3+GmK1gwWp3eadQaO+Z/ISQmhI=";
  };
  livechat-deps = fetchNpmDeps {
    name = "${livechat-pname}-${livechat-version}-npm-deps";
    src = livechat-src;
    hash = "sha256-atXmU6wAh0zLG6jsUwi1GBXexYbJvGvDiGHHdFdAm5k=";
  };

  conversejs-pname = "conversejs-livechat";
  conversejs-version = "10.0.0";
  conversejs-src = fetchFromGitHub {
    owner = "JohnXLivingston";
    repo = "converse.js";
    rev = "refs/tags/livechat-${conversejs-version}";
    hash = "sha256-YyaCmq/BXcxPe512w8mPBk5OP1zKmywyGqgdQIiGz5c=";
  };
  conversejs-deps = fetchNpmDeps {
    name = "${conversejs-pname}-${conversejs-version}-npm-deps";
    src = conversejs-src;
    hash = "sha256-1ObgAiaIsXK6ACxdNjRWxmRYClDfHZ3BdBb+47EsD4Q=";
  };

  merged-src = stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "peertube-plugin-livechat-src-full";
    version = livechat-version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      cp -r --no-preserve=mode,ownership ${livechat-src} $out
      mkdir -p $out/vendor
      cp -r --no-preserve=mode,ownership ${conversejs-src} $out/vendor/${conversejs-pname}-${conversejs-version}

      runHook postInstall
    '';
  });

  merged-patched-src = buildNpmPackage {
    pname = "${conversejs-pname}-src-patched";
    version = conversejs-version;

    src = merged-src;

    postPatch = ''
      substituteInPlace conversejs/build-conversejs.sh \
        --replace-fail '/bin/env node' 'node' \
        --replace-fail 'if [[ ! -d "$converse_build_dir/node_modules" ]]; then' 'echo "Done patching ConverseJS" && exit 0; if [[ ! -d "$converse_build_dir/node_modules" ]]; then'
    '';

    npmDeps = livechat-deps;

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      bash conversejs/build-conversejs.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      rm -r node_modules
      rm -r vendor/${conversejs-pname}-${conversejs-version}
      mv build/conversejs vendor/${conversejs-pname}-${conversejs-version}
      rmdir build

      cp -r . $out

      runHook postInstall
    '';
  };

  conversejs = buildNpmPackage rec {
    pname = conversejs-pname;
    version = conversejs-version;

    src = merged-patched-src;

    postPatch = ''
      substituteInPlace conversejs/build-conversejs.sh \
        --replace-fail 'converse_build_dir="$rootdir/build/conversejs"' 'converse_build_dir="$converse_src_dir"' \
        --replace-fail 'if cmp -s "$converse_src_dir/package.json" "$converse_build_dir/package.json"' 'echo "Skipping re-modifying of source..."; if false; then if cmp -s "$converse_src_dir/package.json" "$converse_build_dir/package.json"' \
        --replace-fail 'if [[ ! -d "$converse_build_dir/node_modules" ]]; then' 'fi; if [[ ! -d "$converse_build_dir/node_modules" ]]; then'
    '';

    npmRoot = "vendor/${conversejs-pname}-${conversejs-version}";

    npmDeps = conversejs-deps;

    makeCacheWritable = true;

    buildPhase = ''
      runHook preBuild

      bash conversejs/build-conversejs.sh

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist/client/conversejs $out

      runHook postInstall
    '';
  };
in
buildNpmPackage rec {
  pname = "peertube-plugin-livechat";
  version = "10.0.2";

  src = merged-src;

  patches = [
    # Fix EPIPE when talking to prosodyctl process
    # Remove when fix for https://github.com/JohnXLivingston/peertube-plugin-livechat/issues/416 merged & in Nixpkgs / release
    (fetchpatch {
      name = "0001-peertube-plugin-livechat-Fix-EPIPE.patch";
      url = "https://github.com/JohnXLivingston/peertube-plugin-livechat/commit/ad27a76fab884ae1d939aee094ec7414ee174ab7.patch";
      excludes = [ "CHANGELOG.md" ];
      hash = "sha256-sfLPeYStXlkX9QVEIlyNovojNyUl8GUPzEY4w1EiBxI=";
    })

    # Change default, we don't want to bother with downloading & including a bundled prosody AppImage
    ./9000-Default-to-using-system-installed-prosody.patch
  ];

  npmDeps = livechat-deps;

  postPatch = ''
    mkdir -p dist/client
    cp -r --no-preserve=mode,ownership ${conversejs} dist/client/conversejs

    # clean:light would get rid of the built conversejs
    # conversejs is already built, build:prosody would try to download an AppImage
    substituteInPlace package.json \
      --replace-fail '"build:avatars": "./build-avatars.js"' '"build:avatars": "node ./build-avatars.js"' \
      --replace-fail '"build": "npm-run-all -s clean:light' '"build": "npm-run-all -s' \
      --replace-fail 'build:prosodymodules build:converse build:prosody' 'build:prosodymodules'

    substituteInPlace conversejs/build-conversejs.sh \
      --replace-fail '/bin/env node' 'node'

    # We don't want to rely on a bundled AppImage version of prosody
    substituteInPlace server/lib/settings.ts \
      --replace-fail 'default: false' 'default: true'

    # Wants to run its own prosody instance
    substituteInPlace server/lib/prosody/config.ts \
      --replace-fail "exec = 'prosody'" "exec = '${lib.getExe' prosody "prosody"}'" \
      --replace-fail "execCtl = 'prosodyctl'" "execCtl = '${lib.getExe' prosody "prosodyctl"}'" \
  '';

  # Don't try to delete & rebuild everything when installing the plugin in peertube
  postInstall = ''
    substituteInPlace $out/lib/node_modules/${pname}/package.json \
      --replace-fail '"prepare": "npm run clean && npm run build",' ""
  '';

  strictDeps = true;

  meta = {
    description = "Provides chat system for Peertube videos";
    homepage = "https://github.com/JohnXLivingston/peertube-plugin-livechat";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ OPNA2608 ];
    platforms = lib.platforms.unix;
  };
}
