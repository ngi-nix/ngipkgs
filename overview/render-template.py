import sys
from jinja2 import Template
from markdown_it import MarkdownIt

jinja2_template_file = sys.argv[1]
output_file = sys.argv[2]

md = MarkdownIt("commonmark")

with open(jinja2_template_file) as file:
  jinja2_template = Template(file.read())

rendered = jinja2_template.render(markdown_to_html=md.render)

with open(output_file, "w") as file:
  file.write(rendered)
