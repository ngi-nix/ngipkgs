{
  fetchFromGitHub,
  lib,
  ...
}:
finalMixPkgs: previousMixPkgs: {
  ex_cldr = previousMixPkgs.ex_cldr.overrideAttrs (previousAttrs: {
    # Explanation: use the GitHub sources instead of Hex,
    # as it otherwise tries to download the locales when building reverse-dependencies.
    src = fetchFromGitHub {
      owner = "elixir-cldr";
      repo = "cldr";
      rev = "v${previousAttrs.version}";
      hash = lib.readFile ex_cldr/hash;
    };

    postInstall = previousAttrs.postInstall or "" + ''
      cp $src/priv/cldr/locales/* $out/lib/erlang/lib/ex_cldr-${previousAttrs.version}/priv/cldr/locales/
    '';
  });
}
