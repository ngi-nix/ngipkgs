{
  lib,
  stdenv,

  buildNpmPackage,
  fetchFromGitHub,
  electron,
  chromium,
  clojure,

  writeShellScriptBin,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  replaceVars,
  nix-update-script,

  vulkan-loader,
}:
buildNpmPackage (finalAttrs: {
  pname = "repath-studio";
  version = "0.4.10";

  src = fetchFromGitHub {
    owner = "repath-project";
    repo = "repath-studio";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xV4/vJ3t9s1JPd++rTMngiVXB78/OHyKDNVGrCjufBk=";
  };

  patches = [
    (replaceVars ./hardcode-git-paths.patch {
      clj-kdtree_src = fetchFromGitHub {
        owner = "abscondment";
        repo = "clj-kdtree";
        rev = "5ec321c5e8006db00fa8b45a8ed9eb0b8f3dd56d";
        hash = "sha256-ZOv+9TxBsOnSSbfM7kJLP3cQH9FpgA15aETszg7YSes=";
      };
    })
  ];

  makeCacheWritable = true;

  npmDepsHash = "sha256-/Wj//cxM3bhBeU8LIyA/fMO9MZHoNs15apKBzhx6sCQ=";

  nativeBuildInputs = [
    finalAttrs.passthru.clojureWithCache
    makeWrapper
    copyDesktopItems
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = true;
    PUPPETEER_SKIP_DOWNLOAD = true;
  };

  postPatch = ''
    substituteInPlace shadow-cljs.edn \
      --replace-fail ":shadow-git-inject/version" '"v${finalAttrs.version}"'
  '';

  passthru = {
    # this was taken and adapted from "logseq" package's nixpkgs derivation
    mavenRepo = stdenv.mkDerivation {
      name = "repath-studio-${finalAttrs.version}-maven-deps";
      inherit (finalAttrs) src patches;

      nativeBuildInputs = [ clojure ];

      buildPhase = ''
        runHook preBuild

        export HOME="$(mktemp -d)"
        mkdir -p "$out"

        # -P       -> resolve all normal deps
        # -M:alias -> resolve extra-deps of the listed aliases
        clj -Sdeps "{:mvn/local-repo \"$out\"}" -P -M:dev:cljs

        runHook postBuild
      '';

      # copied from buildMavenPackage
      # keep only *.{pom,jar,sha1,nbm} and delete all ephemeral files with lastModified timestamps inside
      installPhase = ''
        runHook preInstall

        find $out -type f \( \
          -name \*.lastUpdated \
          -o -name resolver-status.properties \
          -o -name _remote.repositories \) \
          -delete

        runHook postInstall
      '';

      dontFixup = true;

      outputHash = "sha256-wytFeZkVE6zAivyTwF5wv8SgskocN33FzhojOjETWog=";
      outputHashMode = "recursive";
      outputHashAlgo = "sha256";
    };

    clojureWithCache = writeShellScriptBin "clojure" ''
      exec ${lib.getExe' clojure "clojure"} -Sdeps '{:mvn/local-repo "${finalAttrs.passthru.mavenRepo}"}' "$@"
    '';
  };

  buildPhase = ''
    runHook preBuild

    # electronDist needs to be modifiable on Darwin
    cp -r ${electron.dist} electron-dist
    chmod -R u+w electron-dist
  ''
  # Electron builder complains about symlink in electron-dist
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    rm electron-dist/libvulkan.so.1
    cp ${lib.getLib vulkan-loader}/lib/libvulkan.so.1 electron-dist
  ''
  + ''
    npm run build
    npm exec electron-builder -- --dir \
      -c.electronDist=electron-dist \
      -c.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    ${
      if stdenv.hostPlatform.isDarwin then
        # bash
        ''
          mkdir -p $out/Applications
          cp -r "dist/mac"*"/Repath Studio.app" "$out/Applications"
          makeWrapper "$out/Applications/Repath Studio.app/Contents/MacOS/Repath Studio" "$out/bin/repath-studio"
        ''
      else
        # bash
        ''
          mkdir -p $out/share/{repath-studio,icons/hicolor/scalable/apps}
          cp -r dist/*-unpacked/resources/app.asar $out/share/repath-studio
          cp resources/public/img/icon.svg $out/share/icons/hicolor/scalable/apps/repath-studio.svg

          makeWrapper '${lib.getExe electron}' "$out/bin/repath-studio" \
            --add-flags "$out/share/repath-studio/app.asar" \
            --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
            --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
            --inherit-argv0
        ''
    }

    runHook postInstall
  '';

  # chromium package not available for darwin
  doCheck = stdenv.hostPlatform.isLinux;
  checkPhase = ''
    runHook preCheck
    export ELECTRON_OVERRIDE_DIST_PATH=electron-dist/
    export PUPPETEER_EXECUTABLE_PATH=${chromium}/bin/chromium
    npm run test
    unset ELECTRON_OVERRIDE_DIST_PATH
    runHook postCheck
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "Repath Studio";
      desktopName = "Repath Studio";
      exec = "repath-studio %U";
      type = "Application";
      terminal = false;
      icon = "repath-studio";
      comment = "Vector graphics editor, that combines procedural tooling with traditional design workflows";
      categories = [ "Graphics" ];
    })
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    changelog = "https://github.com/repath-project/repath-studio/blob/v${finalAttrs.version}/CHANGELOG.md";
    description = "Cross-platform vector graphics editor, that combines procedural tooling with traditional design workflows";
    homepage = "https://repath.studio";
    downloadPage = "https://github.com/repath-project/repath-studio";
    license = lib.licenses.agpl3Only;
    mainProgram = "repath-studio";
    maintainers = with lib.maintainers; [ phanirithvij ];
    teams = with lib.teams; [ ngi ];
    platforms = electron.meta.platforms;
  };
})
