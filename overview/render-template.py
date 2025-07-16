import sys
import os

from jinja2 import Template
from markdown_it import MarkdownIt
from pygments import highlight
from pygments.lexers import get_lexer_by_name
from pygments.formatters import HtmlFormatter

jinja2_template_file = sys.argv[1]
output_root = sys.argv[2]
output_path = sys.argv[3]
screenshots_path = sys.argv[4]

output_file = output_root + "/" + output_path

# Include code from a file and highlight it in HTML
def include_code(language, file_path, relative_path=False):
  if relative_path:
    file_path = os.path.dirname(output_file) + "/" + file_path
  with open(file_path) as file:
    code = file.read()
    try:
        lexer = get_lexer_by_name(language, stripall=True)
        formatter = HtmlFormatter(cssclass="code")
        return highlight(code, lexer, formatter)
    except Exception:
        print("Fallback: Return the code without highlighting")
        return f'<pre class="shell" class="shell"><code>{code}</code></pre>'

def generate_usage_instructions(usage_instructions):
  return '\n'.join((f'''
  <li>
    <p>{instruction['instruction']}</p>
    <img class="page-width" src="{screenshots_path}/{instruction['screenshot']}" />
  </li>
  ''' for instruction in usage_instructions))

md = MarkdownIt("commonmark")

with open(jinja2_template_file) as file:
  jinja2_template = Template(file.read())

rendered = jinja2_template.render(markdown_to_html=md.render, include_code=include_code, generate_usage_instructions=generate_usage_instructions)

with open(output_file, "w") as file:
  file.write(rendered)
