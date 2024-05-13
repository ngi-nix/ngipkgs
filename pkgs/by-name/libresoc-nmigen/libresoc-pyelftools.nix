{
  lib,
  python39Packages,
  fetchFromGitHub,
}:
python39Packages.pyelftools.overrideAttrs (_: rec {
  name = "pyelftools";
  version = "unstable-2024-03-31";

  # upstream Libre-SOC uses a mirror,
  # and while this would be best handled as github.com/Libre-SOC-mirrors copy,
  # an included GitHub workflow interferes with the automated mirror.
  # instead,
  src = fetchFromGitHub {
    owner = "eliben";
    repo = name;
    rev = "8b97f5da6838791fd5c6b47b1623fb414daed2f0";
    hash = "sha256-E+grMrl0NJMl+yUzRyzTVIb/MjMOUOgq6YynGJhnMZg=";
  };

  meta = {
    description = "Library for analyzing ELF files and DWARF debugging information";
    homepage = "https://git.libre-soc.org/?p=pyelftools.git;a=summary";
    license = lib.licenses.unlicense;
  };
})
