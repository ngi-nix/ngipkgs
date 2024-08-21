{
  writeShellApplication,
  git,
}:
writeShellApplication {
  name = "deploy-ngipkgs";
  runtimeInputs = [ git ];
  text = ''
    git clone -b howto-docs --no-checkout --depth=1 https://github.com/ngi-nix/ngipkgs.git deploy-ngipkgs && # clone an empty version of ngipkgs to a dir called deploy-ngipkgs
    cd deploy-ngipkgs &&
    git checkout howto-docs -- projects && # checkout only the projects directory of ngipkgs
    cp -a projects/. . && # copy contents of the projects directory into the root of deploy-ngipkgs
    rm -rf .git projects default.nix && # cleanup
    git init && git add . # create a new git repo for tracking config changes during deployment
  '';
}
