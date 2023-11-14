{
  description = "Noise Socket library in OCaml";

  # we're using this commit since the required dependencies aren't in master yet
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/9e14dd7220446ed5889138e024f33dfe367556d0";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "armv7l-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      supportedOcamlPackages = [
        "ocamlPackages_4_10"
        "ocamlPackages_4_11"
        "ocamlPackages_4_12"
      ];
      defaultOcamlPackages = "ocamlPackages_4_12";

      forAllOcamlPackages = nixpkgs.lib.genAttrs supportedOcamlPackages;
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor =
        forAllSystems (system:
          import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
          });
    in
    {
      overlay = final: prev:
        with final;
        let mkOcamlPackages = prevOcamlPackages:
          with prevOcamlPackages;
          let ocamlPackages = {
            inherit buildDunePackage angstrom lwt noise ounit stdint;
            inherit ocaml;
            inherit findlib;
            inherit ocamlbuild;
            inherit opam-file-format;

            noise-socket =
              buildDunePackage rec {
                pname = "noise-socket";
                version = "0.0.1";
                src = self;

                useDune2 = true;

                nativeBuildInputs = with ocamlPackages; [ odoc ];

                propagatedBuildInputs = with ocamlPackages; [
                  angstrom
                  noise
                  stdint
                ];

                doCheck = true;
                checkInputs = [
                  lwt
                  ounit
                ];
              };
          };
          in ocamlPackages;
        in
        let allOcamlPackages =
          forAllOcamlPackages (ocamlPackages:
            mkOcamlPackages ocaml-ng.${ocamlPackages});
        in
        allOcamlPackages // {
          ocamlPackages = allOcamlPackages.${defaultOcamlPackages};
        };

      packages =
        forAllSystems (system:
          forAllOcamlPackages (ocamlPackages:
            nixpkgsFor.${system}.${ocamlPackages}));

      defaultPackage =
        forAllSystems (system:
          nixpkgsFor.${system}.ocamlPackages.noise-socket);
    };
}
