{
  buildGo115Module,
  fetchFromGitHub,
  lib,
}:
buildGo115Module {
  pname = "ipfs-crawler";
  version = "unstable-2021-07-28";

  src = fetchFromGitHub {
    owner = "ipfs-search";
    repo = "ipfs-search";
    rev = "0730dc2f33a1f841d4f4c43d3c3f5d70c66cceb9";
    hash = "sha256-JJem8vghPH+J9THcPDSJjXe1LK2S7NX3A3Uawze3FUA=";
  };

  vendorSha256 = "sha256-bz427bRS0E1xazQuSC7GqHSD5yBBrDv8o22TyVJ6fho=";

  meta = {
    description = "Search engine for the Interplanetary Filesystem";
    homepage = "https://ipfs-search.com";
    license = with lib.licenses; agpl3Only;
  };
}
