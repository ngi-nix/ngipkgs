{ ... }:
{
  services.proximity_matcher_webservice = {
    enable = true;
    hashesPicklePath = "/var/lib/proximity_matcher_webservice/hashes.pickle";
    hashesPath = "/var/lib/proximity_matcher_webservice/hashes";
  };
}
