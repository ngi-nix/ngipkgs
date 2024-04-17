# vnu complains about self-closing tags `<meta ... />` and `<link ... />`
# in pandoc's output. See <https://github.com/jgm/pandoc/discussions/9345>.
# Use sed to rewrite those tags.
s#<\(link\|meta\) \(.*\) />#<\1 \2>#
