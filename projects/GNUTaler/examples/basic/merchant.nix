{ ... }:
let
  CURRENCY = "KUDOS";
in
{
  services.taler = {
    settings.taler.CURRENCY = CURRENCY;
    merchant = {
      enable = true;
      debug = true;
      openFirewall = true;
      settings.merchant-exchange-test = {
        EXCHANGE_BASE_URL = "http://exchange:8081/";
        MASTER_KEY = "2TQSTPFZBC2MC4E52NHPA050YXYG02VC3AB50QESM6JX1QJEYVQ0";
        inherit CURRENCY;
      };
    };
  };
}
