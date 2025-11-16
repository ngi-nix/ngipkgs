{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  python3,
  python3Packages,
  enableContrib ? true,
  apply_patch_py,
  ...
}:
let
  inherit (lib.strings) cmakeBool;
in
(python3Packages.opencv4.override {
  inherit enableContrib;
  # Explanation: match CMAKE_OPENCV_IMG_CODER_SELECTION in evision/Makefile
  enableEXR = true;
  enableJPEG = true;
  enableJPEG2000 = true;
  enablePNG = true;
  enableTIFF = true;
  enableWebP = true;
}).overrideAttrs
  (
    finalAttrs: previousAttrs: {
      # Explanation: nixpkgs's opencv-4.12.0 is not (yet) supported by evision-0.2.14
      # and more specifically, gen2.py's flags where changed substantialy in opencv-4.12.0:
      # https://github.com/opencv/opencv/pull/27325
      #
      # ToDo(maintenance/update): once evision supports opencv-4.12.0
      # this version may be able to match nixpkgs' version.
      version = "4.11.0";

      src = fetchFromGitHub {
        owner = "opencv";
        repo = "opencv";
        tag = finalAttrs.version;
        hash = "sha256-oiU4CwoMfuUbpDtujJVTShMCzc5GsnIaprC4DzkSzEM=";
      };
      patches = [
        # ToDo(maintenance/update): remove this patch on opencv-4.12.0
        #
        # Explanation: frontporting opencv-4.11.0 to nixos-25.11
        # stumbles on the new cmake-4 in nixos-25.11,
        # which deprecated too old cmake_minimum_required() in CMakeLists.txt
        # that BUILD_JASPER=ON + WITH_ADE=ON still expects.
        (fetchpatch2 {
          name = "Fix-configuring-with-CMake-version-4.patch";
          url = "https://github.com/opencv/opencv/pull/27192.patch";
          hash = "sha256-1yzOU9xR5LmdxzczM4sXuDyZ/DCLJApAQMUQE2mmAlg=";
        })
      ];

      # Explanation: nixos-25.11#opencv4's contribSrc's version
      # is not using finalAttrs.version
      # so override postUnpack with the correct one.
      opencvContribSrc = fetchFromGitHub {
        owner = "opencv";
        repo = "opencv_contrib";
        tag = finalAttrs.version;
        hash = "sha256-YNd96qFJ8SHBgDEEsoNps888myGZdELbbuYCae9pW3M=";
      };
      postUnpack = ''
        cp --no-preserve=mode -r "${finalAttrs.opencvContribSrc}/modules" "$NIX_BUILD_TOP/source/opencv_contrib"
      '';

      nativeBuildInputs = previousAttrs.nativeBuildInputs or [ ] ++ [ python3 ];

      # Explanation(compatibility): evision has an unusual way to patch opencv:
      # a Python script.
      postPatch = ''
        python3 ${apply_patch_py} . ${finalAttrs.version}
      '';

      cmakeFlags =
        previousAttrs.cmakeFlags
        ++ [
          (cmakeBool "BUILD_EXAMPLES" false)
          (cmakeBool "INSTALL_C_EXAMPLES" false)
          (cmakeBool "BUILD_opencv_gapi" false)
          (cmakeBool "BUILD_opencv_apps" false)
          (cmakeBool "BUILD_opencv_java" false)
          (cmakeBool "BUILD_opencv_gapi" false)
          # Explanation: evision enables JASPER
          (cmakeBool "BUILD_JASPER" true)
        ]
        ++ lib.optionals enableContrib [
          # Explanation: evision disables them;
          # don't know why but let's not look for more troubles.
          (cmakeBool "BUILD_opencv_freetype" false)
          (cmakeBool "BUILD_opencv_hdf" false)
          (cmakeBool "BUILD_opencv_sfm" false)

          # Explanation: evision has no bindings for those yet
          (cmakeBool "BUILD_opencv_datasets" false)
          (cmakeBool "BUILD_opencv_dnn_objdetect" false)
          (cmakeBool "BUILD_opencv_dpm" false)
          (cmakeBool "BUILD_opencv_optflow" false)
          (cmakeBool "BUILD_opencv_videostab" false)
          (cmakeBool "BUILD_opencv_xobjdetect" false)
        ];

      pythonImportsCheck = [
        "cv2"
        # Explanation: when enableContrib,
        # SfM is disabled in cmakeFlags (using BUILD_opencv_sfm).
        #"cv2.sfm"
      ];

      # Explanation(compatibility):
      # > [evision] uses and modifies gen2.py and hdr_parser.py
      # > from the python module in the OpenCV repo so that they output header files
      # > that can be used in Elixir bindings
      #
      # For that evision needs a headers.txt generated for Python
      # listing the .hpp files to consider.
      # Unfortunately those files are absolute path in $NIX_BUILD_TOP,
      # they need to be fixed to point to $out, and installed there.
      postInstall = previousAttrs.postInstall or "" + ''
        OPENCV_HEADERS_TXT=$NIX_BUILD_TOP/$sourceRoot/build/modules/python_bindings_generator/headers.txt
        mkdir -p $out/modules/python_bindings_generator/
        while IFS= read -r header; do
          h=$(realpath --relative-to "$NIX_BUILD_TOP" "$header")
          install -Dm644 "$header" "$out/$h"
          echo "$out/$h"
        done <"$OPENCV_HEADERS_TXT" >$out/modules/python_bindings_generator/headers${lib.optionalString enableContrib "-contrib"}.txt
      '';
    }
  )
