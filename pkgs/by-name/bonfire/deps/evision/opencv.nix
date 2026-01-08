{
  lib,
  fetchFromGitHub,
  fetchpatch2,
  python3,
  python3Packages,
  enableContrib ? true,
  enableCuda ? false,
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
        # stumbles on the new ffmpeg-8 in nixos-25.11.
        # Issue: https://github.com/opencv/opencv/issues/27688
        (fetchpatch2 {
          name = "FFmpeg 8.0 support";
          url = "https://github.com/opencv/opencv/pull/27691.patch";
          hash = "sha256-wRL2mLxclO5NpWg1rBKso/8oTO13I5XJ6pEW+Y3PsPc=";
        })

        # ToDo(maintenance/update): remove this patch on opencv-4.12.0
        #
        # Explanation: frontporting opencv-4.11.0 to nixos-25.11
        # stumbles on the new cmake-4 in nixos-25.11,
        # which deprecated too old cmake_minimum_required() in CMakeLists.txt
        # that BUILD_JASPER=ON + WITH_ADE=ON still expects.
        (fetchpatch2 {
          name = "Fix configuring with CMake version 4";
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

          # Explanation: from evision/mix.exs:@module_configuration
          (cmakeBool "BUILD_opencv_calib3d" true)
          (cmakeBool "BUILD_opencv_core" true)
          (cmakeBool "BUILD_opencv_dnn" true)
          (cmakeBool "BUILD_opencv_features2d" true)
          (cmakeBool "BUILD_opencv_flann" true)
          (cmakeBool "BUILD_opencv_highgui" true)
          (cmakeBool "BUILD_opencv_imgcodecs" true)
          (cmakeBool "BUILD_opencv_imgproc" true)
          (cmakeBool "BUILD_opencv_ml" true)
          (cmakeBool "BUILD_opencv_photo" true)
          (cmakeBool "BUILD_opencv_stitching" true)
          (cmakeBool "BUILD_opencv_ts" true)
          (cmakeBool "BUILD_opencv_video" true)
          (cmakeBool "BUILD_opencv_videoio" true)

          # Explanation: from evision/mix.exs:@module_configuration
          (cmakeBool "BUILD_opencv_gapi" false)
          (cmakeBool "BUILD_opencv_world" false)
          (cmakeBool "BUILD_opencv_python2" false)
          (cmakeBool "BUILD_opencv_python3" false)
          (cmakeBool "BUILD_opencv_java" false)

          # Explanation: from evision/Makefile:CMAKE_OPENCV_IMG_CODER_SELECTION
          (cmakeBool "BUILD_JASPER" true)
          # Explanation: from evision/Makefile
          (cmakeBool "BUILD_opencv_apps" false)
        ]
        ++ lib.optionals enableContrib [
          # Explanation: from evision/Makefile
          (cmakeBool "BUILD_opencv_freetype" false)
          (cmakeBool "BUILD_opencv_hdf" false)

          # Explanation: from evision/mix.exs:@module_configuration
          (cmakeBool "BUILD_opencv_aruco" true)
          (cmakeBool "BUILD_opencv_barcode" true)
          (cmakeBool "BUILD_opencv_bgsegm" true)
          (cmakeBool "BUILD_opencv_bioinspired" true)
          (cmakeBool "BUILD_opencv_dnn_superres" true)
          (cmakeBool "BUILD_opencv_face" true)
          (cmakeBool "BUILD_opencv_hfs" true)
          (cmakeBool "BUILD_opencv_img_hash" true)
          (cmakeBool "BUILD_opencv_line_descriptor" true)
          (cmakeBool "BUILD_opencv_mcc" true)
          (cmakeBool "BUILD_opencv_plot" true)
          (cmakeBool "BUILD_opencv_quality" true)
          (cmakeBool "BUILD_opencv_rapid" true)
          (cmakeBool "BUILD_opencv_reg" true)
          (cmakeBool "BUILD_opencv_rgbd" true)
          (cmakeBool "BUILD_opencv_saliency" true)
          (cmakeBool "BUILD_opencv_shape" true)
          (cmakeBool "BUILD_opencv_stereo" true)
          (cmakeBool "BUILD_opencv_structured_light" true)
          (cmakeBool "BUILD_opencv_surface_matching" true)
          (cmakeBool "BUILD_opencv_text" true)
          (cmakeBool "BUILD_opencv_tracking" true)
          (cmakeBool "BUILD_opencv_wechat_qrcode" true) # Disabled on ios or xros
          (cmakeBool "BUILD_opencv_xfeatures2d" true)
          (cmakeBool "BUILD_opencv_ximgproc" true)
          (cmakeBool "BUILD_opencv_xphoto" true)

          # Explanation: from evision/mix.exs:@module_configuration
          (cmakeBool "BUILD_opencv_datasets" false)
          (cmakeBool "BUILD_opencv_dnn_objdetect" false)
          (cmakeBool "BUILD_opencv_dpm" false)
          (cmakeBool "BUILD_opencv_optflow" false)
          (cmakeBool "BUILD_opencv_sfm" false)
          (cmakeBool "BUILD_opencv_videostab" false)
          (cmakeBool "BUILD_opencv_xobjdetect" false)
        ]
        ++ lib.optionals enableCuda [
          # Explanation: from evision/mix.exs:@module_configuration
          (cmakeBool "BUILD_opencv_cudaarithm" false)
          (cmakeBool "BUILD_opencv_cudabgsegm" false)
          (cmakeBool "BUILD_opencv_cudacodec" false)
          (cmakeBool "BUILD_opencv_cudafeatures2d" false)
          (cmakeBool "BUILD_opencv_cudafilters" false)
          (cmakeBool "BUILD_opencv_cudaimgproc" false)
          (cmakeBool "BUILD_opencv_cudalegacy" false)
          (cmakeBool "BUILD_opencv_cudaobjdetect" false)
          (cmakeBool "BUILD_opencv_cudaoptflow" false)
          (cmakeBool "BUILD_opencv_cudastereo" false)
          (cmakeBool "BUILD_opencv_cudawarping" false)
          (cmakeBool "BUILD_opencv_cudev" false)
        ];

      pythonImportsCheck = [
        # Explanation: fail with enabled modules.
        # ImportError: OpenCV loader: missing configuration file: ['config-3.13.py', 'config-3.py']. Check OpenCV installation.
        #"cv2"
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
