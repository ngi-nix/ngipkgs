{
  replaceVars,
  perlInterpreter,
  ...
}:

[
  {
    name = "0001-openssl-Patch-script-interpreters.patch";
    patch = replaceVars ./0001-openssl-Patch-script-interpreters.patch.in {
      inherit perlInterpreter;
    };
  }
]
