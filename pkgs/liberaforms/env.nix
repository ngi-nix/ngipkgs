{
  callPackage,
  fetchFromGitHub,
  system,
  ...
}: let
  liberaforms-src = callPackage ./src.nix {};

  # Mach Nix is broken on recent Nixpkgs
  # https://github.com/DavHau/mach-nix/issues/549
  machNixpkgs = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    rev = "554d2d8aa25b6e583575459c297ec23750adb6cb";
    sha256 = "sha256-AXLDVMG+UaAGsGSpOtQHPIKB+IZ0KSd9WS77aanGzgc=";
  };

  machPkgs = import machNixpkgs {inherit system;};

  mach-nix =
    import
    (fetchFromGitHub {
      owner = "DavHau";
      repo = "mach-nix";
      rev = "3.5.0";
      sha256 = "sha256-j/XrVVistvM+Ua+0tNFvO5z83isL+LBgmBi9XppxuKA=";
    })
    {pkgs = machPkgs;};

  requirements = let
    req = builtins.readFile "${liberaforms-src}/requirements.txt";
    #TODO lots of notes here; mach-nix doesnt handle (??xref various issues) range of cryptography package - because it doesnt support pyproject.toml?
    #I don't like this, but doing this is the fastest way to get the cryptography from nixpkgs, which is at 36.0.0 (mach-nix automatically finds it)
    filteredReq = builtins.replaceStrings ["cryptography==36.0.1"] ["cryptography==36.0.0"] req; # for liberaforms > v2.0.1
    # Needed for tests only; TODO upstream should make a dev-requirements.txt or whatever?
    # https://gitlab.com/liberaforms/liberaforms/-/commit/16c893ff539bfb6249b3b02f4c834eb8848c16d5
    extraReq = "factory_boy";
  in ''
    ${filteredReq}
    ${extraReq}
  '';
in
  mach-nix.mkPython {inherit requirements;}
