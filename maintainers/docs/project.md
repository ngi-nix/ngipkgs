
## `lib.project`

NGI-funded software application.

```
project
├── metadata
│   ├── summary
│   ├── subgrants
│   └── links
├── binary
└── nixos
    ├── demo
    │   └── tests
    ├── programs
    │   └── examples
    │       └── tests
    └── services
        └── examples
            └── tests
```

### Checks

After implementing one of a project's components:

1. Verify that its checks are successful:

  ```shellSession
  nix-build -A checks.PROJECT_NAME
  ```

1. Run the tests, if they exist, and make sure they pass:

  ```shellSession
  nix-build -A projects.PROJECT_NAME.nixos.tests.TEST_NAME
  ```

1. [Run the overview locally](https://github.com/eljamm/ngipkgs/blob/docs/render/CONTRIBUTING.md#running-and-testing-the-overview-locally), navigate to the project page and make sure that the options and examples shows up correctly

1. [Make a Pull Request on GitHub](https://github.com/eljamm/ngipkgs/blob/docs/render/CONTRIBUTING.md#how-to-create-pull-requests-to-ngipkgs)

## `lib.metadata`

### Options

- `summary`

  Short description of the project

- `subgrants`

  Funding that projects receive from NLnet (see [subgrant](#libsubgrant))

- `links`

  Resources that may help with packaging (see [link](#liblink))

## `lib.subgrant`

Funding that software authors receive from NLnet to support various software projects.
Each subgrant comes from a fund, which is in turn bound to a grant agreement with the European commission.

In NGIpkgs, we track: `Commons`, `Core`, `Entrust` and `Review`.
While the first three are current fund themes, `Review` encompasses all non-current NGI funds (e.g. Assure, Discovery, PET, ...).

See [NLnet - Thematics Funds](https://nlnet.nl/themes/) for more information.

### Setting subgrants

1. Navigate to the [NLnet project page](https://nlnet.nl/project/index.html)
1. Search for a keyword related to the project (e.g. its name)
1. Confirm that results belong to the same project
1. Add their URL identifiers as subgrants to the project's metadata, with:

  ```
  https://nlnet.nl/project/<IDENTIFIER>/
  ```

> **Example**
>
> For the Nitrokey project, its subgrants are:
>
> ```nix
> metadata.subgrants = {
>   Review = [ "Nitrokey" ];
>   Entrust = [ "Nitrokey-3" ];
>   Commons = [
>     "Nitrokey-Storage"
>     "Nitrokey3-FIDO-L2"
>   ];
> };
> ```
>

## `lib.link`

Resources that may help with packaging and using a software.

> **Example**
>
> ```nix
> metadata.links = {
>   source = {
>     text = "Project repository";
>     url = "https://github.com/ngi-nix/ngipkgs/";
>   };
>   docs = {
>     text = "Documentation";
>     url = "https://github.com/ngi-nix/ngipkgs/blob/main/CONTRIBUTING.md";
>   };
> };
> ```
>

## `lib.binary`

Binary files (raw, firmware, schematics, ...).

> **Example**
>
> ```nix
> binary = {
>   "nitrokey-fido2-firmware".data = pkgs.nitrokey-fido2-firmware;
>   "nitrokey-pro-firmware".data = pkgs.nitrokey-pro-firmware;
> };
> ```
>

## `lib.program`

Software that runs in a shell.

> **Example**
>
> ```nix
> { ... }@args:
> {
>   nixos.modules.programs.PROGRAM_NAME = {
>     module = ./path/to/module.nix;
>     examples."Enable foobar" = {
>       module = ./path/to/examples/basic.nix;
>       description = "Basic configuration example for foobar";
>       tests.basic.module = import ./path/to/tests/basic.nix args;
>     };
>   };
> }
> ```
>

> [!NOTE]
> - Each program must include at least one example, so users get an idea of what to do with it (see [example](#libexample)).
> - Examples must be tested (see [test](#libtest)).

After implementing the program, run the [checks](#checks) to make sure that everything is correct.

## `lib.service`

Software that runs as a background process.

> **Example**
>
> ```nix
> { ... }@args:
> {
>   nixos.modules.services.SERVICE_NAME = {
>     module = ./path/to/module.nix;
>     examples."Enable foobar" = {
>       module = ./path/to/examples/basic.nix;
>       description = "Basic configuration example for foobar";
>       tests.basic.module = import ./path/to/tests/basic.nix args;
>     };
>   };
> }
> ```
>

> [!NOTE]
> - Each service must include at least one example, so users get an idea of what to do with it (see [example](#libexample)).
> - Examples must be tested (see [test](#libtest)).

After implementing the service, run the [checks](#checks) to make sure that everything is correct.

## `lib.example`

Configuration of an application module that illustrates how to use it.

> **Example**
>
> ```nix
> { ... }@args:
> {
>   nixos.modules.services.some-service.examples = {
>     "Basic mail server setup with default ports" = {
>       module = ./services/some-service/examples/basic.nix;
>       description = "Send email via SMTP to port 587 to check that it works";
>       tests.basic.module = import ./path/to/tests/basic.nix args;
>     };
>   };
> }
> ```
>

### Options

- `module`

  File path to a NixOS module that contains the application configuration

- `description`

  Description of the example, ideally with further instructions on how to use it

- `tests`

  At least one test for the example (see [test](#libtest))

- `links`

  Links to related resources (see [link](#liblink))

## `lib.demo`

Practical demonstration of an application.

It provides an easy way for users to test its functionality and assess its suitability for their use cases.

> **Example**
>
> ```nix
> nixos.demo.TYPE = {
>   module = ./path/to/application/configuration.nix;
>   module-demo = ./path/to/demo/only/configuration.nix;
>   usage-instructions = [
>     {
>       instruction = ''
>         Run `foobar` in the terminal
>       '';
>     }
>     {
>       instruction = ''
>         Visit [http://127.0.0.1:8080](http://127.0.0.1:8080) on your browser
>       '';
>     }
>   ];
>   tests = {
>     # See the section for contributing tests
>   };
> };
> ```
>

- Replace `TYPE` with either `vm` or `shell`.
This indicates the preferred environment for running the application: NixOS VM or terminal shell.

- Use `module` for the application configuration and `module-demo` for demo-specific things, like [demo-shell](./overview/demo/shell.nix).
For the latter, it could be something like:

> **Example**
>
> ```nix
> # ./path/to/demo/only/configuration.nix
> {
>   lib,
>   config,
>   ...
> }:
> let
>   cfg = config.programs.foobar;
> in
> {
>   config = lib.mkIf cfg.enable {
>     demo-shell = {
>       programs.foobar = cfg.package;
>       env.TEST_PORT = toString cfg.port;
>     };
>   };
> }
> ```
>

After implementing the demo, run the [checks](#checks) to make sure that everything is correct.

## `lib.test`

NixOS test that ensures that project components behave as intended.

### Adding a NixOS test

You can write a module as outlined in the [NixOS manual](https://nixos.org/manual/nixos/stable/index.html#sec-writing-nixos-tests), then import it with the appropriate arguments:

```nix
{ ... }@args:
{
  tests.basic.module = import ./test.nix args;
}
```

You can also re-use tests from NixOS:

```nix
{ pkgs, ... }@args:
{
  tests.basic.module = pkgs.nixosTests.TEST_NAME;
}
```

### Marking tests as broken

Tests with issues need to be labeled as broken, with a clear description of the problem and links to additional information.

> **Example**
>
> ```nix
> problem.broken.reason = ''
>   The derivation fails to build on python 3.13 due to failing tests.
>
>   For more details, see: https://github.com/pallets-eco/flask-alembic/issues/47
> '';
> ```
>


