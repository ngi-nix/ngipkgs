{
  writeShellApplication,
  git,
}:
let
  repo = fetchGit {
    url = "https://github.com/ngi-nix/ngipkgs/howto-docs";
  };
  storePath = builtins.storePath repo;
in
writeShellApplication {
  name = "deploy-ngipkgs";
  runtimeInputs = [ git ];
  text = ''
    # Create a new directory for the deployment repo
    mkdir ./deploy-ngipkgs

    # Copy projects directory from repo already downloaded to the local store
    cp -r ${storePath}/projects/* ./deploy-ngipkgs

    # Cleanup project files that are not used for deployment
    cd ./deploy-ngipkgs
    find . -type f \( -name 'default.nix' -o -name 'service.nix' -o -name 'container.nix' -o -name 'module.nix' -o -name 'nss*' -o -name 'dbus*' \) -exec rm {} \;
    find . -name 'test*' -exec rm -r {} \;
    find . -type d -empty -delete

    # Create a new git repo for tracking config changes during deployment
    git init && git add .
  '';
}
