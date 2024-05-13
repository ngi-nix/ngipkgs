{fetchgit}: {
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
