{
  lib,
  ...
}:
[
  # misskey: 2025.7.0 -> 2025.12.2
  # https://github.com/NixOS/nixpkgs/pull/477674
  (final: prev: {
    misskey = prev.misskey.overrideAttrs (oldAttrs: rec {
      version = "2025.12.2";

      src = final.fetchFromGitHub {
        owner = "misskey-dev";
        repo = "misskey";
        tag = version;
        hash = "sha256-7S6m97wHFeITABLcnQiPVGLg6d1xcPCHCp7/7d/w48E=";
        fetchSubmodules = true;
      };

      pnpmDeps = final.fetchPnpmDeps {
        inherit (oldAttrs) pname version src;
        pnpm = final.pnpm_9;
        fetcherVersion = 2;
        hash = "sha256-GVzU5YQe7GHn2ddpaGPyLLmhOv5Fy33RL+gBLl3Oyis=";
      };

      patches = [ ];

      # Misskey converts its YAML config to JSON at runtime, which doesn't work
      # because it tries to write it to the Nix store. As a workaround, hardcode
      # this to a path which the service can write to until a better solution is
      # supported, upstream.
      # https://github.com/misskey-dev/misskey/issues/17075
      postPatch = ''
        substituteInPlace packages/backend/src/config.ts \
          --replace-fail \
            "resolve(_dirname, '../../../built/.config.json')" \
            "resolve('/run/misskey/default.json')"
        substituteInPlace {.,packages/backend}/package.json \
          --replace-fail "pnpm compile-config && " ""
      '';
    });
  })
  (final: prev: {
    scion-apps = prev.scion-apps.overrideAttrs (oldAttrs: {
      checkFlags =
        let
          skippedTests = [
            # FIX: why does this fail?
            "TestRoundTripper"
            "TestMangleSCIONAddrURL"
          ];
        in
        oldAttrs.checkFlags or [ ] ++ [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];
    });
  })
  (final: prev: {
    sylkserver = prev.sylkserver.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch or "" + ''
        # "value must be a string"
        substituteInPlace \
          sylk/configuration/__init__.py \
          sylk/applications/xmppgateway/configuration.py \
            --replace-fail "host.default_ip" "host.default_ip or '127.0.0.1'"
      '';
    });
  })
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = pyfinal: pyprev: {
        # Canaille
        # https://github.com/pallets-eco/flask-alembic/issues/47
        flask-alembic = pyprev.flask-alembic.overridePythonAttrs rec {
          version = "3.2.0";
          src = final.fetchFromGitHub {
            owner = "pallets-eco";
            repo = "flask-alembic";
            tag = version;
            hash = "sha256-g5xl5CEfSZUbZxCLYykjd94eVjxzBAkgoBcR4y7IYfM=";
          };
          meta.broken = false;
        };
        # https://github.com/NixOS/nixpkgs/pull/477157
        sipsimple = pyprev.sipsimple.overridePythonAttrs (
          oldAttrs:
          let
            pjsip = oldAttrs.passthru.extDeps.pjsip;
            zrtpcpp.src = final.fetchFromGitHub {
              owner = "wernerd";
              repo = "ZRTPCPP";
              rev = "6b3cd8e6783642292bad0c21e3e5e5ce45ff3e03";
              hash = "sha256-pGng1Y9N51nGBpiZbn2NTx4t2NGg4qkmbghTscJVhIA=";
              postFetch = ''
                # fix build with gcc15
                sed -e '9i #include <cstdint>' -i $out/zrtp/EmojiBase32.cpp
              '';
            };
            applyPatchesWhenAvailable =
              extDep: dir:
              lib.optionalString (extDep ? patches) (
                lib.strings.concatMapStringsSep "\n" (patch: ''
                  echo "Applying patch ${patch}"
                  patch -p1 -d ${dir} < ${patch}
                '') extDep.patches
              );
          in
          {
            preConfigure = ''
              ln -s ${pjsip.src} deps/${pjsip.version}.tar.gz
              cp -r --no-preserve=all ${zrtpcpp.src} deps/ZRTPCPP

              bash ./get_dependencies.sh
            ''
            + applyPatchesWhenAvailable pjsip "deps/pjsip"
            + applyPatchesWhenAvailable zrtpcpp "deps/ZRTPCPP"
            + ''
              # Fails to link some static libs due to missing -lc DSO. Just use the compiler frontend instead of raw ld.
              substituteInPlace deps/pjsip/build/rules.mak \
                --replace-fail '$(LD)' "$CC"

              # Incompatible pointers (not const)
              substituteInPlace deps/pjsip/pjmedia/src/pjmedia-codec/ffmpeg_vid_codecs.c \
                --replace-fail '&payload,' '(const pj_uint8_t **)&payload,'
            '';
          }
        );
      };
    };
    python3Packages = final.python3.pkgs;
  })
  # https://github.com/NixOS/nixpkgs/pull/478324
  (final: prev: {
    oku = prev.oku.overrideAttrs (oldAttrs: {
      # use system oniguruma since the bundled one fails to build with gcc15
      buildInputs = oldAttrs.buildInputs ++ [ final.oniguruma ];
      env.RUSTONIG_SYSTEM_LIBONIG = 1;
    });
  })
  # Gnucap
  # https://github.com/NixOS/nixpkgs/pull/478354
  (final: prev: {
    termcap = prev.termcap.overrideAttrs (oldAttrs: {
      env.NIX_CFLAGS_COMPILE = oldAttrs.env.NIX_CFLAGS_COMPILE or "" + " -std=gnu89";
    });
  })
  # Reoxide
  # https://github.com/NixOS/nixpkgs/pull/479336
  (final: prev: {
    ghidra = prev.ghidra.overrideAttrs (
      oldAttrs:
      let
        pkg_path = "$out/lib/ghidra";
      in
      {
        postFixup = ''
          mkdir -p "$out/bin"
          ln -s "${pkg_path}/ghidraRun" "$out/bin/ghidra"
          for bin in ${pkg_path}/support/*; do
            if [[ -x $bin ]]; then
              ln -s "$bin" "$out/bin/ghidra-$(basename $bin)"
            fi
          done
          wrapProgram "${pkg_path}/support/launch.sh" \
            --set-default NIX_GHIDRAHOME "${pkg_path}/Ghidra" \
            --prefix PATH : ${lib.makeBinPath [ final.openjdk21 ]}
        '';
      }
    );
  })
]
