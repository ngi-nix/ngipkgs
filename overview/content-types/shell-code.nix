{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options = {
    prompt = mkOption {
      type = types.str;
    };
    input = mkOption {
      type = types.lines;
    };
    output = mkOption {
      type = with types; nullOr lines;
      default = null;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self: with lib; ''
          <pre><code>${trim ''
            ${self.prompt} ${self.input}
            ${optionalString (!isNull self.output) self.output}
          ''}</code></pre>
        '';
    };
  };
}
