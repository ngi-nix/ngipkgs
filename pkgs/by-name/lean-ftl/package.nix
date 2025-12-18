{
  lib,
  callPackage,
  pkgsCross,
  linkFarmFromDrvs,
}:

let
  crossTargets = {
    arm-embedded = [
      "cortex-m0"
      "cortex-m23"
      "cortex-m3"
      "cortex-m33"
      "cortex-m35p"
      "cortex-m4"
      "cortex-m52"
      "cortex-m55"
      "cortex-m7"
      "cortex-m85"
      "nucleo-u5a5zj-q"
      "stm32l5"
      "stm32u5"
    ];

    riscv32-embedded = [
      "ch32v307"
      "ch32v307-none-embed"
      "ch32v307-wch-elf"
      "rv32imc"
    ];
  };

  allTargets = {
    default = "linux";
  }
  // crossTargets;

  linux = callPackage ./common.nix { targets = allTargets; };

  crossPackages = lib.concatMapAttrs (
    toolchain: targets:
    let
      mkCrossDrv =
        target:
        pkgsCross.${toolchain}.callPackage ./common.nix {
          inherit target;
          targets = allTargets; # for conditionals
        };
    in
    lib.genAttrs targets mkCrossDrv
  ) crossTargets;
in
{
  inherit linux;

  # Combine all derivations into a single one
  # $ nix-build -A lean-ftl.release
  release = linkFarmFromDrvs "lean-ftl-release" ([ linux ] ++ (lib.attrValues crossPackages));
}
// crossPackages
