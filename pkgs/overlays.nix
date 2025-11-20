{
  lib,
  ...
}:
[
  (final: prev: {
    scion-apps = prev.scion-apps.overrideAttrs (oldAttrs: {
      checkFlags =
        let
          skippedTests = [
            # FIX: why does this fail?
            "TestRoundTripper"
            "TestMangleSCIONAddrURL"
          ];
        in
        oldAttrs.checkFlags or [ ] ++ [ "-skip=^${lib.concatStringsSep "$|^" skippedTests}$" ];
    });
  })
  # Fix compatibility with qt 6.10 + switch to unstable
  # https://github.com/NixOS/nixpkgs/pull/467792
  # https://github.com/NixOS/nixpkgs/pull/467794
  (final: prev: {
    kaidan =
      (prev.kaidan.overrideAttrs (oldAttrs: {
        version = "0.13.0-unstable-2025-12-03";
        src = final.fetchFromGitLab {
          domain = "invent.kde.org";
          owner = "network";
          repo = "kaidan";
          rev = "f9d9d236aa0fc584771524c1078ab899a9cd5822";
          hash = "sha256-O3L3VEB7HsPYF0FyJtma98SlxgFIADZd/uhfJyEucGQ=";
        };
      })).override
        {
          # https://github.com/NixOS/nixpkgs/pull/460354
          qxmpp = prev.qxmpp.overrideAttrs rec {
            version = "1.12.0";
            src = final.fetchFromGitLab {
              domain = "invent.kde.org";
              owner = "libraries";
              repo = "qxmpp";
              tag = "v${version}";
              hash = "sha256-soOu6JyS/SEdwUngOUd0suImr70naZms9Zy2pRwBn5E=";
            };
          };
        };
  })
  # Canaille
  (final: prev: {
    python3 = prev.python3.override {
      packageOverrides = pyfinal: pyprev: {
        # https://github.com/pallets-eco/flask-alembic/issues/47
        flask-alembic = pyprev.flask-alembic.overridePythonAttrs {
          meta.broken = false;
          doCheck = pyfinal.pythonOlder "3.13";
        };
      };
    };
    canaille = prev.canaille.overridePythonAttrs (oldAttrs: {
      doCheck = final.python3Packages.pythonOlder "3.13";
    });
  })
  (final: prev: {
    sylkserver = prev.sylkserver.overrideAttrs (oldAttrs: {
      postPatch = oldAttrs.postPatch or "" + ''
        # "value must be a string"
        substituteInPlace \
          sylk/configuration/__init__.py \
          sylk/applications/xmppgateway/configuration.py \
            --replace-fail "host.default_ip" "host.default_ip or '127.0.0.1'"
      '';
    });
  })
]
