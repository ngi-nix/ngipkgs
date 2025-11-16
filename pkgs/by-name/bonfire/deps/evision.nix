# FixMe(functional/completeness): nix build -f bonfire.mixNixDeps.evision succeeds
# but give a warning of troubles ahead regarding flann_distance_t:

# evision> [ 25%] Building CXX object CMakeFiles/evision.dir/c_src/evision.cpp.o
# evision> [ 50%] Building CXX object CMakeFiles/evision.dir/c_src/modules/evision_cuda.cc.o
# evision> [ 75%] Building CXX object CMakeFiles/evision.dir/c_src/modules/evision_cuda_ipc.cc.o
# evision> /build/evision-0.2.14/c_src/evision.cpp:146:32: warning: inline function âstatic ERL_NIF_TERM Evision_Converter<T, TEnable>::from(ErlNifEnv*, const T&) [with T = cvflann::flann_algorithm_t; TEnable = void; ERL_NIF_TERM = long unsigned int; ErlNifEnv = enif_environment_t]â used but never defined
# evision>   146 |     static inline ERL_NIF_TERM from(ErlNifEnv *env, const T& src);
# evision>       |                                ^~~~
# evision> /build/evision-0.2.14/c_src/evision.cpp:146:32: warning: inline function âstatic ERL_NIF_TERM Evision_Converter<T, TEnable>::from(ErlNifEnv*, const T&) [with T = cvflann::flann_distance_t; TEnable = void; ERL_NIF_TERM = long unsigned int; ErlNifEnv = enif_environment_t]â used but never defined
# evision> /build/evision-0.2.14/c_src/evision.cpp:145:24: warning: inline function âstatic bool Evision_Converter<T, TEnable>::to(ErlNifEnv*, ERL_NIF_TERM, T&, const ArgInfo&) [with T = cvflann::flann_distance_t; TEnable = void; ErlNifEnv = enif_environment_t; ERL_NIF_TERM = long unsigned int]â used but never defined
# evision>   145 |     static inline bool to(ErlNifEnv *env, ERL_NIF_TERM obj, T& p, const ArgInfo& info);
#
# …
#
# evision> 16:13:28.938 [warning] Failed to load nif: {:load_failed, ~c"Failed to load NIF library: '/build/evision-0.2.14/_build/prod/lib/evision/priv/evision.so: undefined symbol: _ZN17Evision_ConverterIN7cvflann16flann_distance_tEvE2toEP18enif_environment_tmRS1_RK7ArgInfo'"}
# evision>
# evision> 16:13:28.951 [warning] The on_load function for module evision_nif returned:
# evision> {:error,
# evision>  {:load_failed,
# evision>   ~c"Failed to load NIF library: '/build/evision-0.2.14/_build/prod/lib/evision/priv/evision.so: undefined symbol: _ZN17Evision_ConverterIN7cvflann16flann_distance_tEvE2toEP18enif_environment_tmRS1_RK7ArgInfo'"}}
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

      # Explanation: generate bindings for Erlang too, instead of only for Elixir.
      env.EVISION_COMPILE_WITH_REBAR = "true";

      nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [
        cmake # For EVISION_SO in Makefile
        which # For setting SHELL_EXEC in Makefile
        python3 # For running gen2.py in Makefile
        elixir # For erl in Makefile
      ];

      buildInputs = previousAttrs.buildInputs or [ ] ++ [
        finalAttrs.passthru.opencv # For NIXPKGS_CMAKE_PREFIX_PATH
      ];
      env.EVISION_PREFER_PRECOMPILED = "false";
      env.OPENCV_VER = finalAttrs.passthru.opencv.version;
      env.EVISION_ENABLE_CONTRIB = if enableOpenCVContrib then "true" else "false";
      env.EVISION_ENABLE_CUDA = if cudaSupport then "true" else "false";
      env.CUDA_TOOLKIT_ROOT_DIR = lib.optionalString cudaSupport cudaPackages.cudatoolkit;

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
        };
      };
    }
  );
}
