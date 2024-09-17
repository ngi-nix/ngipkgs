{
  lib,
  writeText,
  ngipkgs,
  git,

}:
let

#  repo = fetchGit {
#    url = "https://github.com/ngi-nix/ngipkgs/howto-docs";
#  };
#  storePath = builtins.storePath repo;

  # Function to generate lines for modules with examples
  generateLines = lib.concatStrings (lib.mapAttrsToList (name: module:
    if module ? example then ''
      services.${name} = import ../ngipkgs/nixosModules/${name};
      example.${name} = import ../ngipkgs/nixosModules/${name}/example.nix;
    '' else ""
  ) ngipkgs.nixosModules);

  # Function to update flake content
  updateFlakeContent = flakeContent:
    lib.replaceStrings
      ["# GENERATE-HERE"]
      [generateLines]
      flakeContent;

in
derivation {
  name = "deploy-ngipkgs";
  system = builtins.currentSystem;
  builder = "${pkgs.bash}/bin/bash";
  args = [
    "-c"
    ''
      # Create a new directory for the deployment repo
      mkdir ./deploy-ngipkgs

      # Copy projects directory from repo already downloaded to the local store
      cp -r ${ngipkgs.outPath}/projects/* ./deploy-ngipkgs

      # Cleanup project files that are not used for deployment
      cd ./deploy-ngipkgs
      find . -type f \( -name 'default.nix' -o -name 'service.nix' -o -name 'container.nix' -o -name 'module.nix' -o -name 'nss*' -o -name 'dbus*' \) -exec rm {} \;
      find . -name 'test*' -exec rm -r {} \;
      find . -type d -empty -delete

      # Get the flake.nix from the ngipkgs source in the Nix store
      flakeFile="${ngipkgs.outPath}/projects/flake.nix"

      # Read the original content, update it, and write to the deploy repo
      originalContent=$(cat "$flakeFile")
      updatedContent=$(nix-instantiate --eval --expr '(${updateFlakeContent "''${originalContent}"})' --raw)
      echo "$updatedContent" > ./projects/flake.nix

      # Replace the default flake.nix with the generated version
      # cp ${updatedFlakeFile} ./flake.nix

      # Create a new git repo for tracking config changes during deployment
      git init && git add .

      # Meet the nix requirement that a derivation outputs to the store
      touch $out
   ''
  ];
}
