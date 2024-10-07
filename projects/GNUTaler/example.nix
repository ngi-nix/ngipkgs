{
  lib,
  pkgs,
  ...
}: let
  CURRENCY = "KUDOS";
  FIAT_CURRENCY = "CHF";

  testExchange = {
    MASTER_PUBLIC_KEY = "2TQSTPFZBC2MC4E52NHPA050YXYG02VC3AB50QESM6JX1QJEYVQ0";
    BASE_URL = "http://localhost:8081/";
  };
in {
  services.taler = {
    # Import exchange account into Taler's main config
    # https://docs.taler.net/taler-exchange-manual.html#exchange-bank-account-configuration
    includes = [./conf/taler-accounts.conf];

    settings = {
      taler.CURRENCY = CURRENCY;
    };

    exchange = {
      enable = true;
      debug = true;
      openFirewall = true; # default 8081
      # Generated with `taler-harness deployment gen-coin-config`
      # See https://docs.taler.net/taler-exchange-manual.html#coins-denomination-keys
      denominationConfig = lib.readFile ./conf/taler-denominations.conf;
      settings = {
        exchange = testExchange;
        exchange-offline = {
          # WARN: This file will be world-readable. You should either point to
          # a location outside the Nix store or set up secret management.
          # See https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes
          MASTER_PRIV_FILE = "${./conf/private.key}";
        };
      };
    };

    merchant = {
      enable = true;
      debug = true;
      openFirewall = true; # default 8083
      settings = {
        # Add exchange to the list of trusted payment service providers
        # See https://docs.taler.net/taler-merchant-manual.html#exchange
        merchant-exchange-test = {
          EXCHANGE_BASE_URL = testExchange.BASE_URL;
          MASTER_KEY = testExchange.MASTER_PUBLIC_KEY;
          inherit CURRENCY;
        };
      };
    };
  };

  services.libeufin = {
    bank = {
      enable = true;
      debug = true;
      openFirewall = true; # default 8082
      # Needed for currency conversion to work
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
          X_TALER_BANK_PAYTO_HOSTNAME = "localhost:8082";
          # IBAN_PAYTO_BIC = "SANDBOXX";
          BASE_URL = "localhost:8082";

          SUGGESTED_WITHDRAWAL_EXCHANGE = testExchange.BASE_URL;

          ALLOW_REGISTRATION = "yes";

          REGISTRATION_BONUS_ENABLED = "yes";
          REGISTRATION_BONUS = "${CURRENCY}:100";
          DEFAULT_DEBT_LIMIT = "${CURRENCY}:500";

          # NOTE: For conversion to work, the exchange's bank account must be
          # registered before the bank is started.
          # The `services.libeufin.bank.initialAccounts` option can be used to do this.
          ALLOW_CONVERSION = "yes";
          ALLOW_EDIT_CASHOUT_PAYTO_URI = "yes";

          inherit CURRENCY FIAT_CURRENCY;
        };
      };
    };

    nexus = {
      enable = true;
      debug = true;
      openFirewall = true; # default 8084
      settings = {
        # https://docs.taler.net/libeufin/nexus-manual.html#setting-up-the-ebics-subscriber
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
          # WARN: This file will be world-readable. You should either point to
          # a location outside the Nix store or set up secret management.
          # See https://wiki.nixos.org/wiki/Comparison_of_secret_managing_schemes
          CLIENT_PRIVATE_KEYS_FILE = "${./conf/client-ebics-keys.json}";
          BANK_PUBLIC_KEYS_FILE = "${./conf/bank-ebics-keys.json}";
        };
      };
    };
  };

  # Install CLI wallet
  environment.systemPackages = [pkgs.taler-wallet-core];
}
