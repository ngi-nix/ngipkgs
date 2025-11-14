{
  lib,
  callPackage,
  cudaPackages,
  config,
  cmake,
  which,
  python3,
  elixir,
  enableOpenCVContrib ? true,
  # FixMe(functional/completeness): test whether CUDA actually works. CUDA is not free software.
  cudaSupport ? config.cudaSupport,
  fetchpatch2,
  ...
}:
finalMixPkgs: previousMixPkgs: {
  evision = previousMixPkgs.evision.overrideAttrs (
    finalAttrs: previousAttrs: {
      # Explanation: to build, evision.so requires:
      # 1. OPENCV_CONFIGURATION_PRIVATE_HPP, a private CPP header from opencv.src
      # 2. C_SRC_HEADERS_TXT, a list of CPP headers from python_bindings_generator
      postUnpack = previousAttrs.postUnpack or "" + ''
        cp -at $sourceRoot/c_src/ \
          ${finalAttrs.passthru.opencv.src}/modules/core/include/opencv2/core/utils/configuration.private.hpp \
          ${finalAttrs.passthru.opencv}/modules/python_bindings_generator/headers${lib.optionalString enableOpenCVContrib "-contrib"}.txt
      '';

      patches = [
        # Explanation: avoid errors caused by missing flann symbols.
        # See https://github.com/cocoa-xu/evision/issues/293
        # Revert [PATCH] commented out `cvflann::flann_distance_t` conversion
        (fetchpatch2 {
          name = "commented-out-cvflann-flann_distance_t-conversion
-functions";
          url = "https://github.com/cocoa-xu/evision/commit/4ae5c62ca591e0a0fadb5dcd90ed5149bddfc7c0.patch";
          hash = "sha256-+vM6swrqIK9Xz2R8kRSR+BeF7wBvW6x6d0N/+9FnO5E=";
          revert = true;
        })
      ];

      # Explanation: skip complex rules of the Makefile to build opencv,
      # and let cmake use the opencv provided by nix.
      postPatch = previousAttrs.postPatch or "" + ''
        substituteInPlace CMakeLists.txt \
          --replace-fail 'NO_DEFAULT_PATH' ""
        substituteInPlace Makefile \
          --replace-fail '$(EVISION_SO): $(C_SRC_HEADERS_TXT) $(OPENCV_CONFIG_CMAKE)' '$(EVISION_SO):'
      '';

      # Explanation: the Makefile will run cmake within:
      # mix compile.elixir_make --no-deps-check
      # provisioning needed envvars like MIX_APP_PATH, ENABLED_CV_MODULES and ERTS_INCLUDE_DIR.
      dontUseCmakeConfigure = true;

      nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
        cmake # For EVISION_SO in Makefile
        which # For setting SHELL_EXEC in Makefile
        python3 # For running gen2.py in Makefile
        elixir # For erl in Makefile
      ];

      buildInputs = previousAttrs.buildInputs or [ ] ++ [
        finalAttrs.passthru.opencv # For NIXPKGS_CMAKE_PREFIX_PATH
      ];

      env = previousAttrs.env or { } // {
        # Explanation: generate bindings for Erlang too, instead of only for Elixir.
        EVISION_COMPILE_WITH_REBAR = "true";
        EVISION_PREFER_PRECOMPILED = "false";
        OPENCV_VER = finalAttrs.passthru.opencv.version;
        EVISION_ENABLE_CONTRIB = if enableOpenCVContrib then "true" else "false";
        EVISION_ENABLE_CUDA = if cudaSupport then "true" else "false";
        CUDA_TOOLKIT_ROOT_DIR = lib.optionalString cudaSupport cudaPackages.cudatoolkit;
      };

      # Explanation: workaround:
      # (File.Error) could not make directory (with -p) "/homeless-shelter/.cache/elixir_make":
      # no such file or directory
      preConfigure = ''
        export ELIXIR_MAKE_CACHE_DIR="$TMPDIR/.cache"
      '';
      passthru = {
        # Explanation: evision binds opencv to Erlang/Elixir,
        # and for that expects a custom and patched opencv…
        opencv = callPackage evision/opencv.nix {
          apply_patch_py = "${finalMixPkgs.evision.src}/patches/apply_patch.py";
          enableContrib = enableOpenCVContrib;
          enableCuda = cudaSupport;
        };
      };
    }
  );
}
