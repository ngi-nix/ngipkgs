{
  lib,
  ...
}:
let
  CURRENCY = "KUDOS";
in
{
  services.taler = {
    settings.taler.CURRENCY = CURRENCY;
    includes = [ ../conf/taler-accounts.conf ];
    exchange = {
      enable = true;
      debug = true;
      openFirewall = true;
      denominationConfig = lib.readFile ../conf/taler-denominations.conf;
      settings = {
        exchange = {
          MASTER_PUBLIC_KEY = "2TQSTPFZBC2MC4E52NHPA050YXYG02VC3AB50QESM6JX1QJEYVQ0";
          BASE_URL = "http://exchange:8081/";
        };
        exchange-offline = {
          MASTER_PRIV_FILE = "${../conf/private.key}";
        };
      };
    };
  };
}
