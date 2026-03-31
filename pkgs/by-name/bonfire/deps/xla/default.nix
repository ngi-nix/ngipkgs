# Adapted from samuela's work in nixpkgs/pkgs/by-name/xl/xla/package.nix
# to use `elixir-nx/xla`'s `//xla/extension:xla_extension` target instead.
{
  bazel_7,
  buildBazelPackage,
  fetchFromGitHub,
  gitMinimal,
  lib,
  llvmPackages_18,
  patchelf,
  python3,
  stdenv,
  which,
  xla,
  xxd,
}:

let
  # XLA requires clang 18 -- gcc and newer clang versions (e.g., 21) fail with
  # stricter template syntax checks in xla/tsl/concurrency/async_value_ref.h
  #
  # ABI compatibility with other Nixpkgs stdenv-built packages can be confirmed
  # by seeing that
  #
  #   ldd $(nix-build -A xla)/lib/libservice.so 2>/dev/null | grep -E '(libstdc\+\+|libc\+\+)'
  #
  # shows libstdc++ as being linked from gcc.
  clangStdenv = llvmPackages_18.stdenv;

  pythonEnv = python3.withPackages (ps: with ps; [ numpy ]);
in
(buildBazelPackage.override { stdenv = clangStdenv; }) {
  pname = "xla";
  version = "0.10.0";

  # Warning: it's very important to pin
  # the very same version as `elixir-nx/xla`
  # to avoid compatibility problems.
  src = fetchFromGitHub {
    owner = "openxla";
    repo = "xla";
    # Same revision as Jax 0.9.0
    # https://github.com/elixir-nx/xla/blob/90e1eedd1e13e61f7bd1f5c4b78b0e14ea714d9b/Makefile#L13
    rev = "bb760b047bdbfeff962f0366ad5cc782c98657e0";
    hash = "sha256-PqOHg9wHrMSROVt2jmL9E1AOABH2khR/bdXnl6wJQ00=";
  };

  bazel = bazel_7; # from .bazelversion

  nativeBuildInputs = [
    gitMinimal
    patchelf
    pythonEnv
    which
    xxd
  ];

  prePatch = ''
    ln -s ${xla.src}/extension xla/extension
    cp -r ${xla.src}/extension/patches .
    bash patches/apply.sh
  '';

  postPatch =
    # Remove the .bazelversion file to allow our Bazel version
    ''
      rm -f .bazelversion
      patchShebangs .
    ''
    # Remove rules_ml_toolchain's hermetic CC toolchain registrations.
    # These try to lazily download LLVM binaries (llvm18_linux_x86_64,
    # sysroot_linux_x86_64_glibc_2_27) during analysis, which fails in the
    # sandboxed build phase. We use our own clang from nixpkgs instead.
    + ''
      sed -i '/^register_toolchains("@rules_ml_toolchain/d' WORKSPACE
    ''
    # Remove @pypi//lit dependencies that trigger rules_python's hermetic
    # Python download for lit test targets (only needed for running lit tests,
    # not building)
    + ''
      substituteInPlace xla/lit.bzl \
        --replace-fail '"@pypi//lit",' "" \
        --replace-fail 'if_oss(["@pypi//lit"])' "[]"
      substituteInPlace xla/mlir_hlo/tests/BUILD \
        --replace-fail 'deps = ["@pypi//lit"],' ""
    ''
    # Hermetic Python patchelf workaround:
    #
    # XLA uses rules_python's hermetic Python toolchain, which downloads a
    # pre-built CPython binary (from python-build-standalone). This binary
    # hardcodes /lib64/ld-linux-x86-64.so.2 as its dynamic linker, which
    # doesn't exist in the nix sandbox.
    #
    # During the deps fetch phase, Bazel's `python_repository` rule downloads
    # the binary, and then a separate `host_toolchain` rule (creating
    # python_3_X_host) tries to *execute* it to verify it works. This fails
    # without patchelf.
    #
    # The patchelf must happen inside the `python_repository` rule itself
    # (between download and verification) -- there is no Bazel hook or nix
    # phase we can use between these two repository rules. So we patch
    # rules_python's python_repository.bzl to run patchelf right after
    # extracting the binary, using NIX_DYNAMIC_LINKER from --repo_env.
    #
    # In the build phase, fetchAttrs.preInstall normalizes all /nix/store
    # paths for reproducibility (breaking the patchelf), so
    # buildAttrs.preConfigure re-patchelfs the binary for the actual build.
    + ''
      cp ${./rules-python-nix-patchelf.patch} third_party/py/rules_python_nix_patchelf.patch
      substituteInPlace third_party/py/python_init_rules.bzl \
        --replace-fail \
          '] + extra_patches,' \
          '"@xla//third_party/py:rules_python_nix_patchelf.patch",
          ] + extra_patches,'
    ''
    # Pin gRPC's rules_go SDK metadata. Without `sdks`, rules_go downloads the
    # live Go release manifest into @go_sdk/versions.json, making the deps tar
    # change whenever go.dev publishes a new release.
    + ''
      cp ${./grpc-pin-go-sdk.patch} third_party/grpc/grpc-pin-go-sdk.patch
      substituteInPlace workspace2.bzl \
        --replace-fail \
          'patch_file = ["//third_party/grpc:grpc.patch"],' \
          'patch_file = [
            "//third_party/grpc:grpc.patch",
            "//third_party/grpc:grpc-pin-go-sdk.patch",
          ],'
    '';

  # Configure XLA for CPU-only build using the official configure.py script.
  # This creates a xla_configure.bazelrc file with the appropriate options.
  # Using clang which matches XLA CI environment.
  # Note: --python_bin_path only sets PYTHON_BIN_PATH; it does not disable
  # rules_python's hermetic Python download (triggered by python_init_toolchains).
  preConfigure = ''
    ${lib.getExe pythonEnv} ./configure.py \
      --backend=CPU \
      --host_compiler=CLANG \
      --clang_path=${lib.getExe clangStdenv.cc}
  '';

  bazelTargets = [
    "//xla/extension:xla_extension"
  ];

  # Tests are disabled - most XLA tests are skipped in OSS builds due to tag
  # filters and size constraints. See https://github.com/openxla/xla/issues/36756.

  bazelFlags = [
    "-c opt"
    # Use sandboxed strategy for most actions, but allow local for genrules
    # and copy actions that have issues with strict sandboxing
    "--spawn_strategy=sandboxed,local"
    "--genrule_strategy=sandboxed,local"
    # Disable bzlmod - XLA uses WORKSPACE for deps and bzlmod would try to
    # access the Bazel Central Registry during the build phase
    "--noenable_bzlmod"
    # Work around missing includes in bundled LLVM headers
    "--cxxopt=-include"
    "--cxxopt=cstdint"
    "--host_cxxopt=-include"
    "--host_cxxopt=cstdint"
    # Exclude targets that have incompatibilities
    "--build_tag_filters=-mobile,-ios,-no_oss,-gpu"
    # Dynamic linker path for patchelf in rules-python-nix-patchelf.patch
    "--repo_env=NIX_DYNAMIC_LINKER=${clangStdenv.cc.libc}/lib/ld-linux-x86-64.so.2"

  ];

  removeRulesCC = false;
  # We need some local_config_* repos (CUDA, ROCm, TensorRT stubs) in the build
  # phase.
  removeLocal = false;

  fetchAttrs = {
    sha256 =
      {
        # Original hash in Nixpkgs
        #x86_64-linux = "sha256-9L+oVq/yHqUGLhzSpwqxfYSJ1bIVcnaZgFVB3sjokXs=";
        # Hash in NGIpkgs
        #x86_64-linux = "sha256-kPWdXOQ03vGNXdX1wbcnhu4Nho/UZqv1RVgFnnyGgzQ=";
        x86_64-linux = "sha256-Kb7bXZFJW2yYCkYrgYI/pI53CzX+q4XJT1OvEVgZBEk=";
      }
      .${stdenv.hostPlatform.system} or (throw "unsupported system: ${stdenv.hostPlatform.system}");
    preInstall =
      # Note: $bazelOut/external is the entire contents of the deps archive (see
      # `deps.installPhase` in buildBazelPackage).
      ''
        chmod -R +w $bazelOut/external
        rm -rf $bazelOut/external/{local_config_python,\@local_config_python.marker}
        rm -rf $bazelOut/external/{local_config_sh,\@local_config_sh.marker}
        rm -rf $bazelOut/external/{local_config_xcode,\@local_config_xcode.marker}
        rm -rf $bazelOut/external/{local_execution_config_python,\@local_execution_config_python.marker}
        rm -rf $bazelOut/external/{local_jdk,\@local_jdk.marker}
      ''
      # Normalize all /nix/store hashes to a fixed value so the deps archive is
      # reproducible regardless of which nixpkgs revision built it. Somehow this
      # does not break the build (yet).
      + ''
        find $bazelOut/external -type f -exec \
          sed -i 's|/nix/store/[a-z0-9]\{32\}-|/nix/store/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa-|g' {} +
      ''
      # Delete non-deterministic Python bytecode (contains timestamps)
      + ''
        find $bazelOut/external -name '*.pyc' -delete
      '';
  };

  buildAttrs = {
    outputs = [ "out" ];

    preConfigure =
      # Fix #!/usr/bin/env shebangs in rules_python -- Bazel-generated Python
      # stubs use #!/usr/bin/env which doesn't exist in the nix sanduox
      ''
        substituteInPlace $bazelOut/external/rules_python/python/private/py_runtime_info.bzl \
          --replace-fail '"#!/usr/bin/env python3"' '"#!${pythonEnv}/bin/python3"'
        substituteInPlace $bazelOut/external/rules_python/python/private/stage1_bootstrap_template.sh \
          --replace-fail '#!/usr/bin/env bash' '#!${clangStdenv.shell}'
        substituteInPlace $bazelOut/external/rules_python/python/private/runtime_env_toolchain.bzl \
          --replace-fail '"#!/usr/bin/env python3"' '"#!${pythonEnv}/bin/python3"'
      ''
      # Re-patchelf hermetic Python binary with the nix dynamic linker
      # (was normalized in fetchAttrs for reproducibility)
      + ''
        for py_dir in $bazelOut/external/python_3_*; do
          if [ -d "$py_dir" ]; then
            find "$py_dir" -type f -executable \
              -exec patchelf --set-interpreter ${clangStdenv.cc.libc}/lib/ld-linux-x86-64.so.2 {} \; 2>/dev/null || true
          fi
        done
      '';

    installPhase = ''
      runHook preInstall
      tar xf bazel-bin/xla/extension/xla_extension.tar.gz
      mv xla_extension $out
      cp --remove-destination $(realpath $out/lib/libxla_extension.so) \
         $out/lib/libxla_extension.so
      runHook postInstall
    '';
  };

  requiredSystemFeatures = [ "big-parallel" ];

  meta = {
    description = "Machine learning compiler for GPUs, CPUs, and ML accelerators";
    homepage = "https://github.com/openxla/xla";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ julm ];
    platforms = [
      "x86_64-linux"
    ];
  };
}
