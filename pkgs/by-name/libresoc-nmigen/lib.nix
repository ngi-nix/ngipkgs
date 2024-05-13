{fetchgit}: {
  # given recent poor availability of upstream https://git.libre-soc.org/,
  # define a dedicated fetcher for current mirror source
  # (currently github.com/Libre-SOC-mirrors, cc @jleightcap @albertchae)
  fetchFromLibresoc = {
    pname,
    hash,
    rev,
    fetchSubmodules ? true,
  }:
    fetchgit {
      url = "https://github.com/Libre-SOC-mirrors/${pname}.git";
      inherit rev hash fetchSubmodules;
    };
}
