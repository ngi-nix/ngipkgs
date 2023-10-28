{
  pkgs,
  fetchgit,
  power-instruction-analyzer,
  libre-soc,
  ...
}:
with pkgs.python3Packages;
  buildPythonPackage {
    pname = "openpower-isa";
    version = "2023-10-28";
    format = "setuptools";

    src = fetchgit {
      url = "https://git.libre-soc.org/git/openpower-isa.git";
      rev = "21f95f5bb243c937aed9f9ef28605f20b33b7b0e";
      hash = "sha256-UqEBEwVnVMgAn2Y64ccYC3zDY/RLCB7463hQbms+arc=";
    };

    patches = [./setup-no-cprop.patch];

    propagatedBuildInputs = [amaranth astor cffi ply pygdbmi libresoc-nmutil];

    nativeCheckInputs = [nose power-instruction-analyzer];

    dontUsePipInstall = true;
    doInstallCheck = false;
  }
