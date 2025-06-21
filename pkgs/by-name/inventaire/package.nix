{
  runCommandNoCC,
  inventaire-unwrapped,
  inventaire-client,
}:

runCommandNoCC "inventaire" { } ''
  cp -r --no-preserve=mode ${inventaire-unwrapped} $out
  chmod +x $out/bin/inventaire

  ln -s ${inventaire-client}/lib/node_modules/inventaire-client $out/lib/node_modules/inventaire/dist/client
''
