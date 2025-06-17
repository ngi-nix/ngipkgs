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
    stdout = mkOption {
      type = with types; nullOr lines;
      default = null;
    };
    stderr = mkOption {
      type = with types; nullOr lines;
      default = null;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default = self: ''
        <div class="code-block">
          <pre class="shell"><code>${lib.trim ''
            ${self.prompt} ${self.input}
            ${lib.optionalString (!isNull self.stdout) self.stdout}
            ${lib.optionalString (!isNull self.stderr) self.stderr}
          ''}</code></pre>
          <div class="code-buttons">
            <template scripted>
              <button class="button copy" onclick="copyInlineToClipboard(this)">
                <span class="copy-label">Copy</span> <script type="application/json">
                  ${builtins.toJSON self.input}
                </script>
              </button>
            </template>
          </div>
        </div>
      '';
    };
  };
}
