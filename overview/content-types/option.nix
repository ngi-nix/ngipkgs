{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (lib)
    types
    mkOption
    concatStringsSep
    drop
    optionalString
    take
    ;

  join = concatStringsSep;
in
{
  options = {
    prefix-length = mkOption {
      type = types.int;
      default = 2;
    };
    loc = mkOption {
      type = with types; listOf str;
    };
    type = mkOption {
      type = types.str;
    };
    default = mkOption {
      type = types.attrs;
      default = { };
    };
    description = mkOption {
      type = types.str;
    };
    readOnly = mkOption {
      type = types.bool;
    };
    option-prefix = mkOption {
      type = types.str;
      default =
        let
          prefix-head = take config.prefix-length config.loc;
          prefix-tail = drop config.prefix-length config.loc;
        in
        ''
          <span class="option-prefix">${join "." prefix-head}.</span><span>${join "." prefix-tail}</span>
        '';
    };
    option-type = mkOption {
      type = types.str;
      default = ''
        <dt>Type:</dt>
        <dd class="option-type"><code>${config.type}</code></dd>
      '';
    };
    option-default = mkOption {
      type = types.str;
      default = optionalString (config.default ? text) ''
        <dt>Default:</dt>
        <dd class="option-default"><code>${config.default.text}</code></dd>
      '';
    };
    option-description = mkOption {
      type = types.str;
      default =
        let
          # This doesn't actually produce a HTML string but a Jinja2 template string
          # literal, that is then replaced by it's HTML translation at the last build
          # step.
          markdownToHtml = markdown: "{{ markdown_to_html(${builtins.toJSON markdown}) }}";
        in
        ''
          <div class="option-description">
          ${markdownToHtml config.description}
          </div>
        '';
    };
    alert-readonly = mkOption {
      type = types.str;
      default = optionalString config.readOnly ''
        <span class="option-alert" title="This option can't be set by users">Read-only</span>
      '';
    };
    alert-update-script = mkOption {
      type = types.str;
      description = "Derivation has a missing update script.";
      default =
        let
          isDrv = config.type == "package";
          optionName = lib.removePrefix "pkgs." config.default.text;
        in
        optionalString (isDrv && !pkgs ? ${optionName}.passthru.updateScript) ''
          <dt>Notes:</dt>
          <dd><span class="option-alert">Missing update script</span> An update script is required for automatically tracking the latest release.</dd>
        '';
    };
    __toString = mkOption {
      type = with types; functionTo str;
      default = self: ''
        <dt class="option-name">
          ${self.option-prefix}
          ${self.alert-readonly}
        </dt>
        <dd class="option-body">
          ${self.option-description}
          <dl>
            ${self.option-type}
            ${self.option-default}
            ${self.alert-update-script}
          </dl>
        </dd>
      '';
    };
  };
}
