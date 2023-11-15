{
  fetchFromGitHub,
  mkYarnPackage,
}:
mkYarnPackage {
  pname = "dweb-search-frontend";
  version = "unstable-2021-07-26";

  src = fetchFromGitHub {
    owner = "ipfs-search";
    repo = "dweb-search-frontend";
    rev = "985b2fa128523eef611e100bc361193e9ef65984";
    hash = "sha256-v1Uv8HVuUjFQR17Hau2C+cHSRe1kvMPIBXqaKAFNYOs=";
  };

  yarnNix = ./yarn.nix;
  yarnLock = ./yarn.lock;

  installPhase = ''
    yarn --offline build
    cp -r deps/dweb-search-frontend/dist $out
  '';

  # don't generate the dist tarball
  # (`doDist = false` does not work in mkYarnPackage)
  distPhase = ''
    true
  '';
}
