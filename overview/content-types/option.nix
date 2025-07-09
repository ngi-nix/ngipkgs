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
    join
    drop
    optionalString
    take
    ;
in
{
  options = {
    # TODO: simplify this / make it dynamic
    prefix-length = mkOption {
      type = types.int;
      description = ''
        Length to visually separate the fixed and moving parts of an option, making
        less specific elements less dominant to reduce cognitive load.
      '';
      default = 2;
    };
    attrpath = mkOption {
      type = with types; listOf str;
      description = ''
        Attribute path in the NixOS options tree.
      '';
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
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        let
          option-prefix =
            let
              prefix-head = take self.prefix-length self.attrpath;
              prefix-tail = drop self.prefix-length self.attrpath;
            in
            ''
              <span class="option-prefix">${join "." prefix-head}.</span><span>${join "." prefix-tail}</span>
            '';
          option-type = ''
            <dt>Type:</dt>
            <dd class="option-type"><code>${self.type}</code></dd>
          '';
          option-default = optionalString (self.default ? text) ''
            <dt>Default:</dt>
            <dd class="option-default"><code>${self.default.text}</code></dd>
          '';
          option-description =
            let
              # This doesn't actually produce a HTML string but a Jinja2 template string
              # literal, that is then replaced by it's HTML translation at the last build
              # step.
              # Also, this avoids IFD (which would make things very slow with a
              # growing number of such strings in the website rendering) since
              # this way we can do markdown processing in a single step per output file at the end
              markdownToHtml = markdown: "{{ markdown_to_html(${builtins.toJSON markdown}) }}";
            in
            ''
              <div class="option-description">
              ${markdownToHtml self.description}
              </div>
            '';
          alert-update-script =
            let
              isDrv = self.type == "package";
              attrPath = lib.splitString "." self.default.text ++ [
                "passthru"
                "updateScript"
              ];
              updateScript = lib.attrByPath attrPath null pkgs;
            in
            # TODO: plug a function that recurses into all dependencies,
            # so we'd know how much of the build graph is kept up to date automatically
            optionalString (isDrv && updateScript == null) ''
              <dt>Notes:</dt>
              <dd><span class="option-alert">Missing update script</span> An update script is required for automatically tracking the latest release.</dd>
            '';
        in
        ''
          <dt class="option-name">
            ${option-prefix}
            ${optionalString self.readOnly ''
              <span class="option-alert" title="This option can't be set by users">Read-only</span>
            ''}
          </dt>
          <dd class="option-body">
            ${option-description}
            <dl>
              ${option-type}
              ${option-default}
              ${alert-update-script}
            </dl>
          </dd>
        '';
    };
  };
}
