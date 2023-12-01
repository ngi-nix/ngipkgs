{
  pkgs,
  lib,
  stdenv,
  fetchPypi,
  substituteAll,
  python3,
}: let
  inherit
    (lib)
    optionals
    licenses
    maintainers
    optionalString
    ;
in
  python3.pkgs.buildPythonPackage rec {
    pname = "Shapely";
    version = "1.8.4";
    disabled = python3.pkgs.pythonOlder "3.6";

    src = fetchPypi {
      inherit pname version;
      sha256 = "sha256-oZXlHKr6IYKR8suqP+9p/TNTyT7EtlsqRyLEz0DDGYw=";
    };

    nativeBuildInputs = with pkgs; [
      pkgs.geos # for geos-config
      python3.pkgs.cython
    ];

    propagatedBuildInputs = with python3.pkgs; [
      numpy
    ];

    checkInputs = with python3.pkgs; [
      pytestCheckHook
    ];

    # Environment variable used in shapely/_buildcfg.py
    GEOS_LIBRARY_PATH = "${pkgs.geos}/lib/libgeos_c${stdenv.hostPlatform.extensions.sharedLibrary}";

    patches = [
      # Patch to search form GOES .so/.dylib files in a Nix-aware way
      (substituteAll {
        src = ./library-paths.patch;
        libgeos_c = GEOS_LIBRARY_PATH;
        libc = optionalString (!stdenv.isDarwin) "${stdenv.cc.libc}/lib/libc${stdenv.hostPlatform.extensions.sharedLibrary}.6";
      })
    ];

    preCheck = ''
      rm -r shapely # prevent import of local shapely
    '';

    disabledTests = optionals (stdenv.isDarwin && stdenv.isAarch64) [
      # FIXME(lf-): these logging tests are broken, which is definitely our
      # fault. I've tried figuring out the cause and failed.
      #
      # It is apparently some sandbox or no-sandbox related thing on macOS only
      # though.
      "test_error_handler_exception"
      "test_error_handler"
      "test_info_handler"
    ];

    pythonImportsCheck = ["shapely"];

    meta = {
      description = "Geometric objects, predicates, and operations";
      homepage = "https://pypi.python.org/pypi/Shapely/";
      license = with licenses; [bsd3];
      maintainers = with maintainers; [knedlsepp];
    };
  }
