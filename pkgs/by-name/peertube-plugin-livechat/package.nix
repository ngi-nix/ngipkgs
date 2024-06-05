{
  lib,
  buildNpmPackage,
  fetchNpmDeps,
  fetchFromGitHub,
  stdenvNoCC,
  symlinkJoin,
  nodePackages,
  npmHooks,
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

  npmDeps = livechat-deps;

  postPatch = ''
    mkdir -p dist/client
    cp -r --no-preserve=mode,ownership ${conversejs} dist/client/conversejs

    substituteInPlace package.json \
      --replace-fail '"build:avatars": "./build-avatars.js"' '"build:avatars": "node ./build-avatars.js"' \
      --replace-fail '"build": "npm-run-all -s clean:light' '"build": "npm-run-all -s' \
      --replace-fail 'build:prosodymodules build:converse build:prosody' 'build:prosodymodules'

    substituteInPlace conversejs/build-conversejs.sh \
      --replace-fail '/bin/env node' 'node'
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
