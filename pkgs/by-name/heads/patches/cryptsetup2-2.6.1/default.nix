{
  replaceVars,
  bashInterpreter,
  ...
}:

[
  {
    name = "0001-cryptsetup-Patch-script-interpreters.patch";
    patch = replaceVars ./0001-cryptsetup-Patch-script-interpreters.patch.in {
      inherit bashInterpreter;
    };
  }
]
