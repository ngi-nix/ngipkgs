let
  CURRENCY = "KUDOS";
  FIAT_CURRENCY = "CHF";
in
{
  services.libeufin.bank = {
    enable = true;
    debug = true;

    openFirewall = true;
    createLocalDatabase = true;

    initialAccounts = [
      {
        username = "exchange";
        password = "exchange";
        name = "Exchange";
      }
    ];

    settings = {
      libeufin-bank = {
        WIRE_TYPE = "x-taler-bank";
        # WIRE_TYPE = "iban";
        X_TALER_BANK_PAYTO_HOSTNAME = "bank:8082";
        # IBAN_PAYTO_BIC = "SANDBOXX";
        BASE_URL = "bank:8082";

        # Allow creating new accounts
        ALLOW_REGISTRATION = "yes";

        # A registration bonus makes withdrawals easier since the
        # bank account balance is not empty
        REGISTRATION_BONUS_ENABLED = "yes";
        REGISTRATION_BONUS = "${CURRENCY}:100";

        DEFAULT_DEBT_LIMIT = "${CURRENCY}:500";

        # NOTE: The exchange's bank account must be initialised before
        # the main bank service starts, else it doesn't work.
        # The `services.libeufin.bank.initialAccounts` option can be used to do this.
        ALLOW_CONVERSION = "yes";
        ALLOW_EDIT_CASHOUT_PAYTO_URI = "yes";

        SUGGESTED_WITHDRAWAL_EXCHANGE = "http://exchange:8081/";

        inherit CURRENCY FIAT_CURRENCY;
      };
    };
  };

  services.libeufin.nexus = {
    enable = true;
    debug = true;

    openFirewall = true;
    createLocalDatabase = true;

    settings = {
      # https://docs.taler.net/libeufin/setup-ebics-at-postfinance.html
      nexus-ebics = {
        # == Mandatory ==
        CURRENCY = FIAT_CURRENCY;
        # Bank
        HOST_BASE_URL = "https://isotest.postfinance.ch/ebicsweb/ebicsweb";
        BANK_DIALECT = "postfinance";
        # EBICS IDs
        HOST_ID = "PFEBICS";
        USER_ID = "PFC00639";
        PARTNER_ID = "PFC00639";
        # Account information
        IBAN = "CH4740123RW4167362694";
        BIC = "BIC";
        NAME = "nixosTest nixosTest";

        # == Optional ==
        CLIENT_PRIVATE_KEYS_FILE = "${../conf/client-ebics-keys.json}";
        BANK_PUBLIC_KEYS_FILE = "${../conf/bank-ebics-keys.json}";
      };
    };
  };
}
