{ inputs }:
{
  imports = [
    # Setup both a master and a worker buildbot instance in this host
    inputs.buildbot-nix.nixosModules.buildbot-master
    inputs.buildbot-nix.nixosModules.buildbot-worker
    ./configuration.nix
    { nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ]; }
  ];
}
