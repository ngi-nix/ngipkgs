{
  wrapFirefox,
  firefox-devedition-unwrapped,
  fetchFirefoxAddon,
  meta-press,
}:

let
  # workaround for https://github.com/NixOS/nixpkgs/issues/273509
  # TODO: remove when nixpkgs rev is updated
  firefox-unwrapped = (
    firefox-devedition-unwrapped.overrideAttrs (previousAttrs: {
      passthru = previousAttrs.passthru // {
        requireSigning = false;
        allowAddonSideload = true;
      };
    })
  );
in
wrapFirefox firefox-unwrapped {
  nixExtensions = [
    (
      (fetchFirefoxAddon {
        name = "meta-press-es"; # Has to be unique!
        src = "${meta-press}/firefox_addon.xpi";
      })
    )
  ];
}
