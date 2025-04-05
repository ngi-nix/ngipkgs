{ ... }:
{
  services.proximity-matcher = {
    enable = true;
    hashesPicklePath = "/var/lib/proximity-matcher/hashes.pickle";
    hashesPath = "/var/lib/proximity-matcher/hashes";
  };
}
