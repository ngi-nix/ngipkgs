{
  python39Packages,
  fetchgit,
}:
python39Packages.pyelftools.overrideAttrs (_: rec {
  name = "libresoc-pyelftools";
  version = "v0.30";
  src = fetchgit {
    url = "https://git.libre-soc.org/git/pyelftools.git";
    rev = version;
    sha256 = "sha256-A9etnN7G24/Gu8YlV/YDpxZV+TG2eVXGx2ZjVnA9ZD4=";
  };
})
