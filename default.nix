{
  sources ? (import ./flake-compat.nix {root = ./.;}).inputs,
  system ? builtins.currentSystem,
  pkgs ?
    import sources.nixpkgs {
      config = {};
      overlays = [];
      inherit system;
    },
}: {
  shell = pkgs.mkShellNoCC {
    packages = [];
  };
}
