{
  description = "Weblate package and module";

  inputs.nixpkgs.url = "github:NixOS/Nixpkgs/nixos-unstable";
  inputs.poetry2nix.url = "github:nix-community/poetry2nix/master";
  inputs.weblate.url = "git+file:///home/kerstin/git/weblate?ref=weblate-4.7.2";
  inputs.weblate.flake = false;

  outputs = { self, nixpkgs, poetry2nix, weblate }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ poetry2nix.overlay ];
      };
    in
    {

      packages.x86_64-linux.weblate = pkgs.poetry2nix.mkPoetryApplication {
        src = weblate;
	pyproject = ./pyproject.toml;
	poetrylock = ./poetry.lock;
        overrides = pkgs.poetry2nix.overrides.withDefaults (
          self: super: {
            ruamel-yaml = super.ruamel-yaml.overridePythonAttrs (old: {
              propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
                self.ruamel-yaml-clib
              ];
            });
	    weblate-language-data = super.weblate-language-data.overridePythonAttrs (old: {
	      buildInputs = (old.buildInputs or [ ]) ++ [
	        self.translate-toolkit
	      ];
	    });
	    borgbackup = super.borgbackup.overridePythonAttrs (old: {
	      BORG_OPENSSL_PREFIX = pkgs.openssl.dev;
	      nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.pkg-config ];
	      buildInputs = (old.buildInputs or [ ]) ++ (with pkgs; [ openssl acl ]);
	    });
          }
        );
      };

      defaultPackage.x86_64-linux = self.packages.x86_64-linux.weblate;

    };
}
