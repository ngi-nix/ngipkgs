{
  lib,
  stdenv,
  fetchFromGitHub,
  runCommand,

  cmake,
  which,

  targets,
  target ? "linux",
}:

let
  isLinux = target == "linux";
  isEmbeddedArm = lib.elem target targets.arm-embedded;
  isEmbeddedRiscv32 = lib.elem target targets.riscv32-embedded;
in

stdenv.mkDerivation (finalAttrs: {
  pname = "lean-ftl-${target}";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "sebastien-riou";
    repo = "lean-ftl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-nFjfoUuBwHwGSNxNLf7otLJvf/KDukSLbhcdTV6MmeE=";
  };

  postPatch = ''
    substituteInPlace cmake/gcc-riscv-none-elf.cmake \
      --replace-fail "riscv-none-elf" "riscv32-none-elf"

    # tests fail with: conflicting CPU architectures ARM v4T vs ARM v8-M.mainline
    substituteInPlace on/nucleo-u5a5zj-q \
      --replace-fail "BUILD_TEST 1" "BUILD_TEST 0"
  '';

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals isEmbeddedArm [
    which
  ];

  outputs = [
    "out"
  ]
  # store tests in a separate output for a faster build
  ++ lib.optionals isLinux [
    "test"
  ];

  cmakeBuildType = "MinSizeRel";

  # sorry, unimplemented: '-fstack-check=specific' for Thumb-1
  hardeningDisable = lib.optionals isEmbeddedArm [
    "stackprotector"
    "stackclashprotection"
    "fortify"
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_TOOLCHAIN_FILE" "on/${target}")
    (lib.cmakeFeature "VERSION_TIMESTAMP" "0")
    (lib.cmakeFeature "GIT_VERSION" "v${finalAttrs.version}")
    (lib.cmakeBool "BUILD_TEST" isLinux)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{lib,include}

    cp liblean-ftl/liblean-ftl.a $out/lib/
    cp -r ../liblean-ftl/include/* $out/include/

    ${lib.optionalString isLinux ''
      mkdir -p $test/bin
      cp lean-ftl-test-fw $test/bin
    ''}

    runHook postInstall
  '';

  # nix-build . -A targets.linux.passthru.tests
  passthru.tests = lib.optionalAttrs isLinux {
    lean-ftl-tests =
      runCommand "lean-ftl-tests"
        {
          nativeBuildInputs = [ finalAttrs.finalPackage.test ];
        }
        ''
          lean-ftl-test-fw
          echo "Success!" > $out
        '';

    example =
      runCommand "lean-ftl-example"
        {
          nativeBuildInputs = [ stdenv.cc ];
          buildInputs = [ finalAttrs.finalPackage ];
        }
        ''
          $CC -o ./hello \
            ${finalAttrs.src}/examples/hello/main.c \
            -llean-ftl

          ./hello > $out

          grep "Hello from lean-ftl" $out
        '';
  };

  meta = {
    description = "Flash translation layer library targeting embedded systems";
    homepage = "https://github.com/sebastien-riou/lean-ftl";
    changelog = "https://github.com/sebastien-riou/lean-ftl/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    mainProgram = "lean-ftl";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [ eljamm ];
    teams = with lib.teams; [ ngi ];
  };
})
