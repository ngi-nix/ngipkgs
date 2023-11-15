{
  fetchFromGitHub,
  npmlock2nix,
  which
}:
npmlock2nix.build {
  pname = "ipfs-search-api-server";
  version = "unstable-2021-04-13";

  # src = "${ipfs-search-api-src}/server";
  src = (fetchFromGitHub {
    owner = "ipfs-search";
    repo = "ipfs-search-api";
    rev = "8a6369d652263e574e026468d854284e1e2221fc";
    hash = "sha256-kQ9Hczgb8CLgbBIlbzpLI5z9mwrVhplL5F9icGjrJKM=";
  } + "/server");

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,lib}

    # copy npmlock2nix modules to lib
    cp -r node_modules $out/lib/node_modules

    # copy source files to lib
    cp -r search $out/lib/search
    cp -r metadata $out/lib/metadata
    for file in esclient.js server.js types.js; do
      echo "#!$(${which}/bin/which node)" > $out/lib/$file
      cat $file >> $out/lib/$file
    done

    chmod +x $out/lib/server.js

    ln -s $out/lib/server.js $out/bin/server
  '';
}
