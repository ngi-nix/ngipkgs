{
  name,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;

  codeBlock.one =
    {
      content,
      copyableContent ? content,
      language ? "bash",
    }:
    ''
      <div class="code-block">
        ${content}
        <div class="code-buttons">
          <template scripted>
            <button class="button copy" onclick="copyInlineToClipboard(this)">
              <script type="application/json">
                ${builtins.toJSON copyableContent}
              </script>
              Copy
            </button>
          </template>
        </div>
      </div>
    '';

in
{
  options = {
    prompt = mkOption {
      type = types.str;
    };
    input = mkOption {
      type = with types; either lines (listOf lines);
    };
    output = mkOption {
      type = with types; nullOr lines;
      default = null;
    };
    __toString = mkOption {
      type = with types; functionTo str;
      readOnly = true;
      default =
        self:
        with lib;
        if lib.isList self.input then
          ''
            <ul>
            ${lib.concatMapStringsSep "\n" (
              i:
              codeBlock.one {
                copyableContent = i;
                content = ''
                  <li><pre class="shell"><code>${trim ''
                    ${self.prompt} ${i}
                    ${optionalString (!isNull self.output) self.output}
                  ''}</code></pre></li>
                '';
              }
            ) self.input}
            </ul>
          ''
        else
          ''
            <pre class="shell"><code>${trim ''
              ${self.prompt} ${self.input}
              ${optionalString (!isNull self.output) self.output}
            ''}</code></pre>
          '';
    };
  };
}
