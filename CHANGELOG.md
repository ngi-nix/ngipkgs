# Changelog

All notable changes to this project will be documented in this file.

## [unreleased]

### CI/CD

- Fix the overview build command - ([642ff47](https://github.com/ngi-nix/ngipkgs/commit/642ff47bb2581c25d53e62353c3e8be32cf921e1))


### Miscellaneous Tasks

- Update CHANGELOG.md - ([e64e735](https://github.com/ngi-nix/ngipkgs/commit/e64e7359b08b465668434a528781f9f613361c9c))


### Build

- Replace manual -> manuals - ([b76b528](https://github.com/ngi-nix/ngipkgs/commit/b76b528ee5b91c3de48e70f01bb6c4f0e3ac6a62))


### Heads

- 0.2.1-unstable-2025-04-03 -> 0.2.1-unstable-2026-02-01 - ([9f4fef5](https://github.com/ngi-nix/ngipkgs/commit/9f4fef55fc71aac4a2187e733dd5f91f10aa357f))
- Drop EOL'd librem targets from default builds - ([028767f](https://github.com/ngi-nix/ngipkgs/commit/028767f2171aec7f4e7182f67b56b4aecbd46366))
- Make coreboot build verbose - ([a86d6a8](https://github.com/ngi-nix/ngipkgs/commit/a86d6a8e293ab299413f7e073b6a9178d5328839))


## [26.01](https://github.com/ngi-nix/ngipkgs/compare/25.12..26.01) - 2026-01-30

### Bug Fixes

- *devLib:* Don't flatten derivation attributes - ([e9663af](https://github.com/ngi-nix/ngipkgs/commit/e9663af9a0d58a92d7ef2976c86576fe1be0dd5f))
- *manuals:* Add missing `defaultText` - ([37037f0](https://github.com/ngi-nix/ngipkgs/commit/37037f0abdf2ac13c6e23bdc72a1c1351b603bcf))
- Wrong optionsDoc for modules - ([81dedc8](https://github.com/ngi-nix/ngipkgs/commit/81dedc8c78a98549b48f1f42f0ec288392099fcf))
- Move anastasis test under the GNUTaler project - ([912fdeb](https://github.com/ngi-nix/ngipkgs/commit/912fdeb04b02fb9c4560ce5d32d597e9992195c3))
- Remove duplicate flake-utils - ([254f1f6](https://github.com/ngi-nix/ngipkgs/commit/254f1f6b8d9c4f920d66c81a6cbf0fdebacf4b45))
- Make scope callPackage aware of call inputs - ([95d7ce1](https://github.com/ngi-nix/ngipkgs/commit/95d7ce1ba94dffce262cb19016a2e03b8a5408a9))
- Docs/project.md generation via nixdoc-to-github - ([6ea5c91](https://github.com/ngi-nix/ngipkgs/commit/6ea5c915584fbd0ce0394becd78ad3595810d30b))


### CI/CD

- Publish overview with manual - ([13334f6](https://github.com/ngi-nix/ngipkgs/commit/13334f645fc6fe3420795648b304584f441dd3bc))
- Check formatting in pre-commit hook - ([ccf6853](https://github.com/ngi-nix/ngipkgs/commit/ccf6853ce7de85bdba8a7900d9e6ae3970cafadd))


### Documentation

- *manuals:* Use ./.version - ([d11b659](https://github.com/ngi-nix/ngipkgs/commit/d11b659f8de79ee523a811c9928eac22cbeae48a))
- *manuals:* Move comment to its proper place - ([24ae8c2](https://github.com/ngi-nix/ngipkgs/commit/24ae8c2ab238e0dbbbc65eccbbcaa104bdf49f27))
- *manuals:* Remove all content from home page - ([56c41da](https://github.com/ngi-nix/ngipkgs/commit/56c41da4412f22196378f61cd8c3629a3d218a9e))


### Features

- *demo:* Enable Nix inside VMs - ([74d7fd8](https://github.com/ngi-nix/ngipkgs/commit/74d7fd8fbad1f6ddae53788d104c9d45ab216c11))
- *demo:* Re-use and write to host store in VMs - ([2cb7c32](https://github.com/ngi-nix/ngipkgs/commit/2cb7c324d13ee7b9d3a3e29a63b6183346536354))
- *manuals:* Init sphinx framework based upon nix.dev - ([3870756](https://github.com/ngi-nix/ngipkgs/commit/38707566ca09797b3f52c12368acc7621bcf88d4))
- Make top-level deliverable attributes consistent - ([54ab9a7](https://github.com/ngi-nix/ngipkgs/commit/54ab9a7f2195b4428d4e169aedc8d965e60eb07a))
- Add manuals and overview-with-manual outputs - ([e84b45c](https://github.com/ngi-nix/ngipkgs/commit/e84b45cf755acccbc28b25d5f3e91d3e138eba2e))
- Use numtide/devshell to improve devshell experience - ([36c6f27](https://github.com/ngi-nix/ngipkgs/commit/36c6f27f3450ccf0c4c6f601f70d84b476720f5f))


### Miscellaneous Tasks

- Remove old project types file - ([b45e2bc](https://github.com/ngi-nix/ngipkgs/commit/b45e2bcdeed49aeca43c9062feafd4d67bbacae6))
- Remove propagated package fixes - ([808572e](https://github.com/ngi-nix/ngipkgs/commit/808572e7f64817da5534bb88eab9bc9a1c35bc5e))


### Overview

- Add devmode for overview+manuals - ([4f8c818](https://github.com/ngi-nix/ngipkgs/commit/4f8c818ebe47686d84ad980f429aee8eb3130f40))


### Refactor

- *overview:* Change Ubuntu platform labels - ([bf4714d](https://github.com/ngi-nix/ngipkgs/commit/bf4714d33980a44bc9a1a8dccf9b0eea9042d047))
- *overview:* Pass args to (sub)modules - ([65942e8](https://github.com/ngi-nix/ngipkgs/commit/65942e836da3d768ce4c94c00dda68220806f8ad))
- *overview:* Make nix-config more readable - ([189d4d3](https://github.com/ngi-nix/ngipkgs/commit/189d4d34ad9ea4723635528917d299b5f3a90b79))
- Separate formatter from git hooks - ([b92794b](https://github.com/ngi-nix/ngipkgs/commit/b92794b88cd61be1bcf797b7bc426d6fe8f79cae))
- Modularize project types - ([dca4f60](https://github.com/ngi-nix/ngipkgs/commit/dca4f60d87d7de9dc23f5d0384e92f34bb258eac))
- Compose project modules as paths - ([958c690](https://github.com/ngi-nix/ngipkgs/commit/958c6900fe8fc35dcd63b8b70b3dd0cf33e0455d))
- Reuse treefmt eval to get the wrapper - ([c40fc77](https://github.com/ngi-nix/ngipkgs/commit/c40fc7726370809881412bcd4f59baa6472944ec))
- Expose project types as an option - ([5ffe840](https://github.com/ngi-nix/ngipkgs/commit/5ffe8407d5c8ec69d4094588858da8c20475d8e4))


### Styling

- *manuals:* Use NGI+Nix logos - ([354e7d8](https://github.com/ngi-nix/ngipkgs/commit/354e7d8f07e1da7a378944d498c920c6f603a0f0))
- *manuals:* Configure theme - ([1ff5976](https://github.com/ngi-nix/ngipkgs/commit/1ff5976285cbe324158714853ec19cd4da4b5d05))
- Format all files - ([bebb1bb](https://github.com/ngi-nix/ngipkgs/commit/bebb1bb7cccc8e4bf17069713007e4036b8642df))
- Fix editorconfig formatting - ([4e4cf89](https://github.com/ngi-nix/ngipkgs/commit/4e4cf896b2758507800f69693a2a4349921096b1))


### Testing

- Improve kmscon font for interactive tests - ([31a7afe](https://github.com/ngi-nix/ngipkgs/commit/31a7afeb3cc18d0900b00fa7247ffff639c2bea3))
- Let the module system merge interactive test configs - ([15b89d1](https://github.com/ngi-nix/ngipkgs/commit/15b89d12a44c7ab405a67cafe543ba0ada110541))


### Build

- *manuals:* Export to flake interface - ([a5f4a2c](https://github.com/ngi-nix/ngipkgs/commit/a5f4a2c36bc9a79258cf794b52ccd3c142f3f8ff))
- *optionsDoc.optionsCommonMark:* Fix missing `description`s - ([4b09cfc](https://github.com/ngi-nix/ngipkgs/commit/4b09cfc2e15aeccf430608c695b15816c470295e))


### Helium

- 5.1.2 -> 6.0.0 - ([84daa28](https://github.com/ngi-nix/ngipkgs/commit/84daa28ab1a500fc87f07d7ed35f141d911f764b))


### Infra/makemake/keys

- Add phanirithvij-iron - ([a48af97](https://github.com/ngi-nix/ngipkgs/commit/a48af976de6d6df1929de8aa0612d5027d872838))


### Maint/update

- *bonfire:* Build `deps.nix` using `--refresh` - ([c28832f](https://github.com/ngi-nix/ngipkgs/commit/c28832f6ef7980834036b6afe4baacedd622a84a))


### Nodebb

- 4.7.2 -> 4.8.0 - ([9846685](https://github.com/ngi-nix/ngipkgs/commit/98466857a2243e30537d3b6b197cc94c71196b46))


### Pagedjs-cli

- 0-unstable-2024-05-31 -> 0-unstable-2026-01-05 - ([51bd9e1](https://github.com/ngi-nix/ngipkgs/commit/51bd9e18a4f47493315e84dc3a59291bcb097e51))


### Pkgs

- *_0wm-server:* Disable automatic update - ([81238fb](https://github.com/ngi-nix/ngipkgs/commit/81238fbe334c063991060882e3aa5bf321fd715b))
- *canaille:* Fix build - ([a8c489f](https://github.com/ngi-nix/ngipkgs/commit/a8c489f952e6fab099ce48e9d1578796cf9c9354))
- *funkwhale:* Fix checks and db connection - ([903f78b](https://github.com/ngi-nix/ngipkgs/commit/903f78b60b4acead7cefafc9f3795fba2f9fc731))
- *gancio:* Fix build by pinning nodejs - ([ecda4ec](https://github.com/ngi-nix/ngipkgs/commit/ecda4ec9d3c5df120bcf5fadb084ff6a9ddbd445))
- *gnucap:* Fix build with gcc15 - ([ceebd22](https://github.com/ngi-nix/ngipkgs/commit/ceebd22d5bfecbd97cdc8cbd06a34d765e7bcaa9))
- *inventaire-i18n:* 0-unstable-2025-11-23 -> 0-unstable-2026-01-05 - ([1503568](https://github.com/ngi-nix/ngipkgs/commit/1503568b168b2d4fedc6dd3aa48ffe79af94833e))
- *kazarma:* 1.0.0-alpha.1-unstable-2025-06-30 -> 1.0.0-alpha.1-unstable-2025-12-24 - ([6b2c7e7](https://github.com/ngi-nix/ngipkgs/commit/6b2c7e7d192c21ce3b8ff8a1e1374cbcfecfcfc7))
- *liberaforms:* Fix build with gcc15 - ([5c9c559](https://github.com/ngi-nix/ngipkgs/commit/5c9c559df452b7791bfe680a76efb9bc5ae0be18))
- *manyfold:* Avoid hardcoding versions - ([d0d854a](https://github.com/ngi-nix/ngipkgs/commit/d0d854a0ca0352f6980d32ff80c66fb9454dd72c))
- *manyfold:* Add update script - ([9309092](https://github.com/ngi-nix/ngipkgs/commit/930909250ada4e4368a50ba8ba9e812faafefda3))
- *manyfold:* 0.129.1 -> 0.131.0 - ([3c06ff1](https://github.com/ngi-nix/ngipkgs/commit/3c06ff1a65617f1684b9fcb60abedf87d5d2c8dc))
- *misskey:* 2025.7.0 -> 2025.12.2 - ([95ceddc](https://github.com/ngi-nix/ngipkgs/commit/95ceddc085fea4b0cf55c4f3b9adbfd5261afc04))
- *nodebb:* 4.7.0 -> 4.7.2 - ([15a93b1](https://github.com/ngi-nix/ngipkgs/commit/15a93b1bbff2a40ff6dffe19b7e6a5bfb365e8b4))
- *oku:* Use system oniguruma and fix build with gcc15 - ([3b530f8](https://github.com/ngi-nix/ngipkgs/commit/3b530f8698b53fb79693deb8fdba1242ce4d83d6))
- *openfire-unwrapped:* 5.0.2 -> 5.0.3 - ([f3884c8](https://github.com/ngi-nix/ngipkgs/commit/f3884c8f418d6d243076cf555693f8ac582cba8f))
- *openxc7:* Fix build with gcc15 - ([dc66c27](https://github.com/ngi-nix/ngipkgs/commit/dc66c277167878934e37b917015139b045fa9179))
- *openxc7:* Refactor nextpnr-xilinx-chipdb composition - ([85783d3](https://github.com/ngi-nix/ngipkgs/commit/85783d3107bfd53c3e60c0ff9272aa728a123286))
- *peertube-plugin-livechat:* 14.0.0 -> 14.0.2 - ([a7114dc](https://github.com/ngi-nix/ngipkgs/commit/a7114dcb211ae1849529e4d8c374d6f5bc664cb6))
- *peertube-plugin-livechat:* Fix build - ([2994bd9](https://github.com/ngi-nix/ngipkgs/commit/2994bd998628d1efed67d368d4204fe441121741))
- *reaction:* Upstreamed to nixpkgs - ([be30dcf](https://github.com/ngi-nix/ngipkgs/commit/be30dcf863afa1a2a166ce03f32e813141ba4074))
- *reoxide:* 0.7.0 -> 0.7.1; fix ghidra - ([dfe493f](https://github.com/ngi-nix/ngipkgs/commit/dfe493f49a3694998d3e1276fb1e52b61e9feca4))
- *repath-studio:* 0.4.11 -> 0.4.12 - ([f7183c9](https://github.com/ngi-nix/ngipkgs/commit/f7183c93711366f0b5619939fea16047e8c0460b))
- *wax-server:* Fix typo in teams - ([2afe4ef](https://github.com/ngi-nix/ngipkgs/commit/2afe4ef553614364971ac1afb7c0cae1cb0783d8))
- Fix sipsimple build with gcc15 - ([7ce179a](https://github.com/ngi-nix/ngipkgs/commit/7ce179a25942e80dd2cb8142a5934cfc6c5f4295))
- Clean up overlays - ([098ca47](https://github.com/ngi-nix/ngipkgs/commit/098ca4747d1e762943af10ed047fce3b2ea413cd))


### Pkgs/py3dtiles

- Init at 12.0.0 - ([75376c6](https://github.com/ngi-nix/ngipkgs/commit/75376c67082b64190fcd390558392e2726d6d48f))


### Projects

- *Forgejo:* Fix test composition; add lts tests - ([f3c63a5](https://github.com/ngi-nix/ngipkgs/commit/f3c63a55811d8337f380254fae31aba02b5b8ee7))
- *Gancio:* Init demo - ([b180f9a](https://github.com/ngi-nix/ngipkgs/commit/b180f9ae3cda323b5b8ae2484378283ff51eb18f))
- *Gancio:* Add links; refactor example - ([95c2ecc](https://github.com/ngi-nix/ngipkgs/commit/95c2ecc8fb5daa00ca904a9f72ad185475c9dbea))
- *Hypermachine:* Disable node libraries - ([d8d8270](https://github.com/ngi-nix/ngipkgs/commit/d8d827071aff1cd0c04185b765b4c605b522db58))
- *Manyfold:* Mark tests as broken - ([3c93466](https://github.com/ngi-nix/ngipkgs/commit/3c934669dd094e2281561ada0b290ebf701b20c5))
- *Mobilizon:* Init - ([561f2e3](https://github.com/ngi-nix/ngipkgs/commit/561f2e3a95425b18d64a5d773f468bc30f6a9641))
- *PeerTube:* Mark livechat plugin as broken - ([3cdc0d0](https://github.com/ngi-nix/ngipkgs/commit/3cdc0d02f65d3d07fded792a4f7801481049bb64))
- *Reaction:* Use module and tests from Nixpkgs - ([dc44dfb](https://github.com/ngi-nix/ngipkgs/commit/dc44dfb5ae9e4e372a426362c04b80df0fa5502e))
- *bonfire:* Init service - ([823184a](https://github.com/ngi-nix/ngipkgs/commit/823184a7ffb9ae7dd87522f65f219741c547c1db))
- *bonfire:* Add demo; refactor - ([4a18558](https://github.com/ngi-nix/ngipkgs/commit/4a18558fed0fa3ece42dac2ddd2066c7690c207f))
- *hockeypuck:* Init - ([f289c87](https://github.com/ngi-nix/ngipkgs/commit/f289c87f935395c252498e82aa0fc7462ac25a33))
- *reaction:* Fix the ssh demo - ([5748663](https://github.com/ngi-nix/ngipkgs/commit/57486636d9caf61921148f2fb884c66abb4ca2c9))


### Projects/Py3DTiles

- Init - ([d37b771](https://github.com/ngi-nix/ngipkgs/commit/d37b77123d8f3e5a19da21c24a9161a36f74c904))


### Reoxide

- 0.7.1 -> 0.7.2 - ([4b7a9f7](https://github.com/ngi-nix/ngipkgs/commit/4b7a9f7ea34d395abff6aaaea63d50db694e2021))


### Reoxide-plugin-simple

- 0-unstable-2025-09-04 -> 0-unstable-2026-01-15 - ([ae14cc3](https://github.com/ngi-nix/ngipkgs/commit/ae14cc32a934d99a56fb6b7525042113ead42934))


### Tau-radio

- 0-unstable-2025-10-13 -> 0.2.101-unstable-2025-12-17 - ([49b0b51](https://github.com/ngi-nix/ngipkgs/commit/49b0b513c5f627934a58ffc83bbb1f8ff75c4b73))


### Tau-tower

- 0-unstable-2025-09-30 -> 0.2.101-unstable-2025-12-17 - ([513b247](https://github.com/ngi-nix/ngipkgs/commit/513b2475f0abf4a4453207fcb1eded0f67838405))


### Unfeat

- *manuals.latexpdf:* Remove code to generate PDFs - ([e4c4af8](https://github.com/ngi-nix/ngipkgs/commit/e4c4af86ea5322c159e97179caf67c7a501184c0))
- *manuals.singlehtml:* Remove code to generate single page HTML - ([bbb1c76](https://github.com/ngi-nix/ngipkgs/commit/bbb1c769d6395c62f16d75745ace11aedcada6c7))


## [25.12](https://github.com/ngi-nix/ngipkgs/compare/25.11..25.12) - 2026-01-12

### Bug Fixes

- *Canaille:* Disable tests; mark unbroken - ([a1e5e27](https://github.com/ngi-nix/ngipkgs/commit/a1e5e27b51d681d364ecb9b8b622311c059cf027))
- *beam-modules:* Vendor-in nixpkgs' helpers - ([2b97fb6](https://github.com/ngi-nix/ngipkgs/commit/2b97fb6e2d0fc8123dda522d5e45fd1dbdf89210))
- *beam-modules:* Improve buildMix and mixRelease - ([b22b4b2](https://github.com/ngi-nix/ngipkgs/commit/b22b4b2ed964b765167026b20b9ced25346b6960))
- Kaidan build with qt 6.10; switch to unstable - ([d67e90f](https://github.com/ngi-nix/ngipkgs/commit/d67e90f2a68172510b8ac248387983169a03605b))
- Nixdoc-to-github paths - ([e84df98](https://github.com/ngi-nix/ngipkgs/commit/e84df9835b90fb3356690bcba55d74ff96c08a2c))


### Documentation

- Clean-up contributing docs - ([618c0b7](https://github.com/ngi-nix/ngipkgs/commit/618c0b71e33d19750d1509085dbdb00d74dfa242))


### Features

- *beam-modules:* Init mixUpdate - ([cb29aec](https://github.com/ngi-nix/ngipkgs/commit/cb29aec0d17fe36fc45a6acd492f55bb81bd1d49))
- Init `customScope` function - ([58487c1](https://github.com/ngi-nix/ngipkgs/commit/58487c19aefea2d2a8717b53810e586dbe39335e))


### Refactor

- Call mkSbtDerivation from pkgs/by-name - ([5444cc9](https://github.com/ngi-nix/ngipkgs/commit/5444cc96c70937206093b54fd6461ca626fcf584))
- Toplevel inputs - ([425db2a](https://github.com/ngi-nix/ngipkgs/commit/425db2a254f6bb391ef826b9ba18ab19d5097a3c))
- Construct toplevel using customScope - ([b5f0cec](https://github.com/ngi-nix/ngipkgs/commit/b5f0cec07af1ec432b734190e996a72022bf9a99))
- Toplevel projects call - ([1db065e](https://github.com/ngi-nix/ngipkgs/commit/1db065ed2d13e3741f92de3734ad498711d902fa))
- Toplevel demo call - ([95131a0](https://github.com/ngi-nix/ngipkgs/commit/95131a03793e09ee4f5fe98bb04e73073056e2d4))
- Toplevel metrics - ([6caf238](https://github.com/ngi-nix/ngipkgs/commit/6caf2382c5815012f1ec5b331048638ecbf27996))
- Move development shell to separate file - ([3be0b6f](https://github.com/ngi-nix/ngipkgs/commit/3be0b6f06b6d437d0af240e87f179807d001657a))
- Toplevel overlays, nixos-modules, and overview - ([f9eb81d](https://github.com/ngi-nix/ngipkgs/commit/f9eb81d621894a71e675b33676ee4f99d2ee3514))
- Move flake checks to separate file - ([5bc4852](https://github.com/ngi-nix/ngipkgs/commit/5bc4852f0a34eae252e7c39a4f2d04c187ad594a))
- Construct flake attributes from default scope - ([54ec3d9](https://github.com/ngi-nix/ngipkgs/commit/54ec3d997fca0c19237e2ca1ded3e96632cf08cd))
- Move toplevel function to checks - ([2247b21](https://github.com/ngi-nix/ngipkgs/commit/2247b21dd1ff2c6d3aa862ec4616ce5e29e1e7c7))
- Dream2nix inputs - ([e7cd36e](https://github.com/ngi-nix/ngipkgs/commit/e7cd36e365edd8d03e948fcd9207c5779cd2efc6))


### Corestore

- Remove in favor of upstream - ([5ab9ac7](https://github.com/ngi-nix/ngipkgs/commit/5ab9ac7ef1c37d9c38cb2ebee4b6739ae7b56525))


### Demo

- Fix trusted-public-keys, case sensitive - ([dfab738](https://github.com/ngi-nix/ngipkgs/commit/dfab738d4a1d00f6c1b958be29163d672badf05f))


### Funkwhale

- Init at 2.0.0-alpha.2 - ([b225675](https://github.com/ngi-nix/ngipkgs/commit/b225675fc62fba6336a6d6384e85a8062e306b09))


### Manyfold

- Init at 0.129.1 - ([6ba7c25](https://github.com/ngi-nix/ngipkgs/commit/6ba7c255a2fd58c8e86b4552df6567b689c61bd7))


### Nodebb

- 4.6.3 -> 4.7.0 - ([16eda3a](https://github.com/ngi-nix/ngipkgs/commit/16eda3a13b9978a3ba1d2f2cbb262741fd35cd0f))


### Pdfding

- Add missing dependencies - ([7d92d59](https://github.com/ngi-nix/ngipkgs/commit/7d92d59fc5354805baf528fd36e77ab553fa3510))


### Peertube-plugin-auto-block-videos

- 0.0.2 -> 0-unstable-2025-11-20 - ([b7ca261](https://github.com/ngi-nix/ngipkgs/commit/b7ca2610fa6eb4123a70f86c714b9dac4115867f))


### Peertube-plugin-auto-mute

- 0.0.6 -> 0-unstable-2025-11-20 - ([b6c28ca](https://github.com/ngi-nix/ngipkgs/commit/b6c28ca5b2c4fe5204e0a55f2195c70c756e9163))


### Peertube-plugin-hello-world

- 0-unstable-2025-05-30 -> 0-unstable-2025-11-20 - ([364b94b](https://github.com/ngi-nix/ngipkgs/commit/364b94b412ffe5a87b4874e1748c8bd876ae5812))


### Peertube-plugin-logo-framasoft

- 0-unstable-2025-05-30 -> 0-unstable-2025-11-20 - ([c4a3228](https://github.com/ngi-nix/ngipkgs/commit/c4a32287529e5c9be8e632334b4a58d9e220ed16))


### Peertube-plugin-matomo

- 1.0.2 -> 0-unstable-2025-11-20 - ([49573ca](https://github.com/ngi-nix/ngipkgs/commit/49573cacf9248262ff15a5d71b31ec45ca27aa26))


### Pkgs

- *anastasis{-gtk}:* Switch to new git repo - ([5b52cdc](https://github.com/ngi-nix/ngipkgs/commit/5b52cdca9627ef9d68ae953e96fb3ac6d7c3df3d))
- *bbb-freeswitch-core:* Bump minimum required cmake version - ([ee3c8a8](https://github.com/ngi-nix/ngipkgs/commit/ee3c8a824aa7c850275f86e2f589318103ae76de))
- *bonfire:* Init at 1.0.1-beta.11 - ([119913d](https://github.com/ngi-nix/ngipkgs/commit/119913d0a16ae0797470b3cda9dbb648e42c0e19))
- *lean-ftl:* Init at 0.1.0 - ([3f6c887](https://github.com/ngi-nix/ngipkgs/commit/3f6c887c490113d84622cbec220cbd90161eb6a4))
- *openfire:* Fix id command; rename to openfire-unwrapped - ([49ac43f](https://github.com/ngi-nix/ngipkgs/commit/49ac43f7419de3a401dd163b6a70240b9063a597))
- *openfire:* Init plugins; wrap package with essential plugins - ([55ceb6e](https://github.com/ngi-nix/ngipkgs/commit/55ceb6ec91539c3cc4a3fe40bea45438b8789b9c))
- *ratmand:* Refactor cargo flags - ([026ed83](https://github.com/ngi-nix/ngipkgs/commit/026ed83c6b3e3df15d36ed0e8d298b22fc69097e))
- *repath-studio:* 0.4.10 -> 0.4.11 - ([2dd3d23](https://github.com/ngi-nix/ngipkgs/commit/2dd3d23aeca126ef0f217cecf667b4da65b0ac51))
- *taldir:* 1.0.5-unstable-2025-10-15 -> 1.0.5-unstable-2025-11-07 - ([8772948](https://github.com/ngi-nix/ngipkgs/commit/877294874894d40531beecce89d870ced37ed27d))


### Projects

- *Kaidan:* Fix and refactor NixOS test - ([8a32b57](https://github.com/ngi-nix/ngipkgs/commit/8a32b57b1a376a3745c4c2308365a2e4a2187de8))
- *MirageOS:* Init - ([815c607](https://github.com/ngi-nix/ngipkgs/commit/815c607e8cd4677b8782d8c9a1818654749da92a))
- *Openfire:* Add declarative autostart settings; refactor - ([f123088](https://github.com/ngi-nix/ngipkgs/commit/f1230887daf668344d06dc556a6d288d2e687835))
- *Openfire:* Refactor example - ([b0e1b95](https://github.com/ngi-nix/ngipkgs/commit/b0e1b956fc3baafd0458e44bf96c448a36a3aa8e))
- *Openfire:* Refactor test - ([789a089](https://github.com/ngi-nix/ngipkgs/commit/789a089706edf9be229412ef475d6c795bde6d59))
- *Openfire:* Enable autosetup - ([ab3b996](https://github.com/ngi-nix/ngipkgs/commit/ab3b996815c649f1800f91d7d99236a527f1401b))
- *Openfire:* Refactor file structure - ([ecb0e5e](https://github.com/ngi-nix/ngipkgs/commit/ecb0e5e2e51863a28a2a0f36a5c1f4ffab10b90c))
- *Openfire:* Add demo - ([79dc26a](https://github.com/ngi-nix/ngipkgs/commit/79dc26a61f951bf5373a0096d7fe0d2d58a36767))
- *Openfire:* Fix users creation on autosetup - ([a35519b](https://github.com/ngi-nix/ngipkgs/commit/a35519bd39f999aecb8585c95fd24db628266fae))
- *PdfDing:* Init examples - ([ca21f09](https://github.com/ngi-nix/ngipkgs/commit/ca21f096a243c37614863adfb988857bdf58d331))
- *PdfDing:* Init nixosTests - ([dbf40a2](https://github.com/ngi-nix/ngipkgs/commit/dbf40a20ce6a49e50bb1a2d2cba84f3317bd2a66))
- *PdfDing:* Init demo - ([26e1952](https://github.com/ngi-nix/ngipkgs/commit/26e19525a2a6a94b57935c01d52da10c2072badf))
- *PdfDing:* Improve demo experience - ([7176b7a](https://github.com/ngi-nix/ngipkgs/commit/7176b7a7ce292d00c73365752fcca4b0d8f1147d))
- *sstorytime:* Simplify database config options - ([7017cc3](https://github.com/ngi-nix/ngipkgs/commit/7017cc3fa6e21bbfa3b7a610918066f1ed025bef))
- *sylk:* Init - ([14fbbe1](https://github.com/ngi-nix/ngipkgs/commit/14fbbe103ae881da8ee9ff7a9dade1e907743b32))


### Projects/Funkwhale

- Init - ([9780991](https://github.com/ngi-nix/ngipkgs/commit/97809917a9fa2b49c52d5ba1c8e253fff1c03478))


### Projects/Manyfold

- Init - ([ceea17b](https://github.com/ngi-nix/ngipkgs/commit/ceea17bee925eff9552a63dd55953b4367942587))
- Add usage instructions - ([05926a0](https://github.com/ngi-nix/ngipkgs/commit/05926a013933c83ca6fcdba40ba24ef5ddb0f1d1))


### Projects/Reaction

- Init project, demo - ([686f6d4](https://github.com/ngi-nix/ngipkgs/commit/686f6d44334372e24ba4a7961cbee3ca49498ede))
- Pull in nixpkgs package, module, tests, examples - ([3d8d8f6](https://github.com/ngi-nix/ngipkgs/commit/3d8d8f6e639d2fa0e63749647cec83059952cf1b))


### Projects/lemmy

- Init - ([3b46497](https://github.com/ngi-nix/ngipkgs/commit/3b46497009ad56ddfd16c9ee8f70e0151d87a52b))


### Projects/owncast

- Init - ([6a78d19](https://github.com/ngi-nix/ngipkgs/commit/6a78d197f2d3552bb70133bc32db7edb7798168b))


### Projects/pdfding

- Init - ([f70e642](https://github.com/ngi-nix/ngipkgs/commit/f70e642952e02145dc1aa3029c9e04556dc9468b))


### Python3-otr

- Remove in favor of python3Packages.otr - ([31ded55](https://github.com/ngi-nix/ngipkgs/commit/31ded55b58e972151649a044dc9eb13fd23edb4b))


### Python3-xcaplib

- Remove in favor of nixpkgs xcaplib - ([7491dff](https://github.com/ngi-nix/ngipkgs/commit/7491dff1ece2809e9e4714e06a85b2090c3ec2c3))


### Quicksasl

- Remove in favor of upstream quick-sasl - ([7c7e1d2](https://github.com/ngi-nix/ngipkgs/commit/7c7e1d29deb34f6bccad238526641ef17ee3b013))


### Shell

- Remove sat-tmp, urwid-satext from update - ([036298a](https://github.com/ngi-nix/ngipkgs/commit/036298aa48bd72c396a025803af8f1011598f453))


### Urwid-satext

- Remove in favor of nixpkgs version - ([345a8af](https://github.com/ngi-nix/ngipkgs/commit/345a8afdee8cd27966014ba7043af62575426424))


## [25.11](https://github.com/ngi-nix/ngipkgs/compare/25.10..25.11) - 2025-12-03

### .github/ISSUE_TEMPLATE

- Project templates cleanup - ([264358a](https://github.com/ngi-nix/ngipkgs/commit/264358a6695a1a72a4f5383cdd126ff4dd9806cf))


### Bug Fixes

- *ci:* Update archlinux packages before installing nix - ([3a55e90](https://github.com/ngi-nix/ngipkgs/commit/3a55e90f2982b9f21a6ff9fc781b09d7079c95b3))
- *demo:* Run command with flakes - ([445d710](https://github.com/ngi-nix/ngipkgs/commit/445d71064db240b1bb916e1496c478b81a2926f7))
- *overview:* Add fallback for overview version - ([732e42b](https://github.com/ngi-nix/ngipkgs/commit/732e42babb2fe010df1182aa65666a029a2e932c))
- Deprecated nixosTest alias - ([d810a80](https://github.com/ngi-nix/ngipkgs/commit/d810a808616d3c262386b7cd79f3677319b8d891))
- Don't evaluate paths in module options - ([2c96428](https://github.com/ngi-nix/ngipkgs/commit/2c96428cd44aa7ce82ac0e2c2036525e91c7d432))


### CI/CD

- Fix changelog config with recent git-cliff - ([d97e169](https://github.com/ngi-nix/ngipkgs/commit/d97e16937ba041ba34138071f13b963a9c674488))
- Add workflow to update changelog - ([f9eb864](https://github.com/ngi-nix/ngipkgs/commit/f9eb86444ab17179447150d5768fe02216edbaad))
- Add automatic package updates workflow - ([fc61170](https://github.com/ngi-nix/ngipkgs/commit/fc611705f7f5593eba749daffb9fd24d93241764))


### Documentation

- *metrics:* Remove Uncategorized grant from metrics - ([e04edb4](https://github.com/ngi-nix/ngipkgs/commit/e04edb49f0074867846a9f2f2cdf19be7e9223f4))
- *report/packaging:* Improve output of packaging report script - ([06fb34d](https://github.com/ngi-nix/ngipkgs/commit/06fb34d9df3df700cc86f00dd7b8131df694d447))
- *report/packaging:* Don't link to demo - ([2eb7ddf](https://github.com/ngi-nix/ngipkgs/commit/2eb7ddf615b1b3d7de204b92e8f88db5d12930da))
- *report/packaging:* Remove redunadant information - ([2852820](https://github.com/ngi-nix/ngipkgs/commit/28528200835d89e2d8e78bc5a4fbbaf50d0ecefb))
- *report/packaging:* Remove Uncategorized grant category - ([15ce3d0](https://github.com/ngi-nix/ngipkgs/commit/15ce3d0d003064964c64b3ba89ba4219161079ca))
- Document metrics summary outputs - ([7bc8973](https://github.com/ngi-nix/ngipkgs/commit/7bc89735d06eaa8cbeaa17992675c127f74c11d5))
- Automate packaging report - ([4123ba6](https://github.com/ngi-nix/ngipkgs/commit/4123ba67587f44dc601f3f78bd87d6f205b546e3))
- Add subgrant details for packaging report - ([c2343e7](https://github.com/ngi-nix/ngipkgs/commit/c2343e7ace499b844af4447d432c237b8954e7ff))
- Fix triaging instructions' bullet point indentation - ([ec296c6](https://github.com/ngi-nix/ngipkgs/commit/ec296c6f3f3af8a251f70c7c18b71b97b3a547ee))
- Add reporting documentation - ([2e3af35](https://github.com/ngi-nix/ngipkgs/commit/2e3af35ed1a4965aa6991fa5f2b3d750a5453f1a))
- Move REPORTING documentation to maintainers dir - ([412df16](https://github.com/ngi-nix/ngipkgs/commit/412df16c87b6d0ed1c687c9bea31722cb36e60e3))


### Features

- *types:* Enforce subgrant structure in metadata - ([60a6e4a](https://github.com/ngi-nix/ngipkgs/commit/60a6e4ac95c69932d89072e49006e19d3b78b506))
- Count maintained derivations in Nixpkgs - ([a807026](https://github.com/ngi-nix/ngipkgs/commit/a807026b1b8d32d733433984bd6be3cc97fb3e5b))
- Apply packages fixes inside tests - ([2f2abc0](https://github.com/ngi-nix/ngipkgs/commit/2f2abc0dc4bc8d0d4a288d8f3161e72e3f51b33b))


### Miscellaneous Tasks

- Update CHANGELOG.md - ([38e1db1](https://github.com/ngi-nix/ngipkgs/commit/38e1db1ae433d3811e2d128ae43da0a3841c47be))
- Remove propagated package fixes - ([b0d23e1](https://github.com/ngi-nix/ngipkgs/commit/b0d23e16c5d91619293b0fcb80284dd3939118cd))
- Disable kazarma and anastasis updates - ([9d57575](https://github.com/ngi-nix/ngipkgs/commit/9d575759d7650d2d3f977d4efb61d000c981ebb3))
- Trim stray newline from demos - ([33d66d2](https://github.com/ngi-nix/ngipkgs/commit/33d66d2457aea32b7874c7a73ccd9e2c908b64d0))


### Overview

- Center footer text - ([ab106e2](https://github.com/ngi-nix/ngipkgs/commit/ab106e290c4d086adb8f9cf4d0f22c7cf82909bf))


### Refactor

- RunCommandNoCC -> runCommand - ([f16859b](https://github.com/ngi-nix/ngipkgs/commit/f16859bf99f9d542f67dda7d768b1a664ac03c2b))
- WrapGAppsHook -> wrapGAppsHook3 - ([617eb28](https://github.com/ngi-nix/ngipkgs/commit/617eb28df751427cf02e18345dfa2cfa5fb40b30))
- Pin flake-inputs hash - ([e76d275](https://github.com/ngi-nix/ngipkgs/commit/e76d275f7751816ab09c02518fbb5f4f049f0c86))
- Use markdown for triage issue template - ([b8ce1fe](https://github.com/ngi-nix/ngipkgs/commit/b8ce1fe0f22eeb74aa91a8eaff8f9a960d5cb4b1))


### _0wm-client

- 0-unstable-2025-10-16 -> 0-unstable-2025-10-27 - ([68c8f17](https://github.com/ngi-nix/ngipkgs/commit/68c8f17c3d4273b82a8daa46b737614f05535835))


### _0wm-opmode

- 0-unstable-2025-09-23 -> 0-unstable-2025-10-27 - ([af350f8](https://github.com/ngi-nix/ngipkgs/commit/af350f8a29b84fb579198efb38c7e05f8a54fea4))


### _0wm-server

- 0-unstable-2025-09-23 -> 0-unstable-2025-11-24 - ([e240591](https://github.com/ngi-nix/ngipkgs/commit/e2405918c162af4364b4ea4170bde56df553f12f))


### Bigbluebutton.bbb-freeswitch-core

- Switch to overriding packages from Nixpkgs - ([6100d24](https://github.com/ngi-nix/ngipkgs/commit/6100d24c92ffc143b3dfecd4a078bfea3e054a61))


### Bigbluebutton.bbb-freeswitch-core.libks

- Reapply patches that fix bugs in tests - ([47bc1cc](https://github.com/ngi-nix/ngipkgs/commit/47bc1cc2dae944dd230f3f01f5f2bb6b03f6ad71))


### Bigbluebutton.bbb-freeswitch-core.libwebsockets

- Reapply CVE fix that is still relevant, drop irrelevant one - ([244a72b](https://github.com/ngi-nix/ngipkgs/commit/244a72bef4388632c08fe5b022f679b73709fdbb))


### Demo

- Refactor and expose in the toplevel - ([1dcbaaa](https://github.com/ngi-nix/ngipkgs/commit/1dcbaaa28218f4ca3b928ffed6181e340fe511fb))


### Helium

- 5.1.1 -> 5.1.2 - ([510242d](https://github.com/ngi-nix/ngipkgs/commit/510242d635a7a799920b087b77696c40a6732d96))


### Inventaire-i18n

- 0-unstable-2025-10-20 -> 0-unstable-2025-11-23 - ([df3b8f4](https://github.com/ngi-nix/ngipkgs/commit/df3b8f413ebb4e8fc1c3f8cf86ce64cf58d22867))


### Meta-press

- 1.9.1 -> 1.9.3 - ([a89fd25](https://github.com/ngi-nix/ngipkgs/commit/a89fd25a44a4b54b26994054384b6cee7d2d9a4c))


### Nodebb

- 4.6.0 -> 4.6.3 - ([f968849](https://github.com/ngi-nix/ngipkgs/commit/f9688491848bc6949438fdbbee3196e87ad5e8e4))


### Peertube-plugin-akismet

- 0-unstable-2025-05-30 -> 0-unstable-2025-11-20 - ([f0786f4](https://github.com/ngi-nix/ngipkgs/commit/f0786f42c5cf1c8d6cf3605c88d3c8168ccdc234))


### Peertube-plugin-auth-ldap

- 0-unstable-2025-05-30 -> 0-unstable-2025-11-20 - ([da34c4d](https://github.com/ngi-nix/ngipkgs/commit/da34c4d8574aaf347c06e5151dd5fc07e4f50048))


### Peertube-plugin-auth-openid-connect

- 0-unstable-2025-05-30 -> 0-unstable-2025-11-20 - ([32d97dd](https://github.com/ngi-nix/ngipkgs/commit/32d97dd26c45702e82d99e00075919aaa043c5f8))


### Peertube-plugin-auth-saml2

- 0.0.8 -> 0-unstable-2025-11-20 - ([e9f6a64](https://github.com/ngi-nix/ngipkgs/commit/e9f6a64fab171709a468920d5d0b75385503a3db))


### Pkgs

- *bigbluebutton.bbb-freeswitch-core:* Fix build - ([7a8239c](https://github.com/ngi-nix/ngipkgs/commit/7a8239ca545796c3402bf8ca3cb3e27683546fca))
- *python3-sipsimple:* Remove stale derivation - ([c478bd9](https://github.com/ngi-nix/ngipkgs/commit/c478bd97b434580772c4282923e85001a8b285b1))
- *repath-studio:* Fix org change - ([49acae1](https://github.com/ngi-nix/ngipkgs/commit/49acae13e9ec91580c2a7adeff4ea8be12bdd56f))
- *sstorytime:* Init at 0.1.2-alpha - ([f625236](https://github.com/ngi-nix/ngipkgs/commit/f625236a33f05500c90beb33c5fa6c7fc548d5d0))
- *sstorytime:* 0.1.2-alpha -> 0.1.3-alpha-unstable-2025-11-17 - ([ee5db30](https://github.com/ngi-nix/ngipkgs/commit/ee5db300ffc30dbe7fd082bf7fb8b5b58f34079c))
- *sstorytime:* Make service port configurable - ([79166fe](https://github.com/ngi-nix/ngipkgs/commit/79166feea01cff3fe9f29d9bcf9261ba23b3dd67))
- *sstorytime:* 0.1.3-alpha-unstable-2025-11-17 -> 0.1.0-beta-unstable-2025-12-01 - ([936fa5a](https://github.com/ngi-nix/ngipkgs/commit/936fa5ab82244a4c7eb7828d3c2de655f7ef4464))


### Pkgs/pdfding

- Init at 1.4.1 - ([0c2dee5](https://github.com/ngi-nix/ngipkgs/commit/0c2dee50eb2cdd6fa200d4adcbb92ae3de1d7a74))


### Pkgs/tau-radio

- Init at 0-unstable-2025-10-13 - ([af033cb](https://github.com/ngi-nix/ngipkgs/commit/af033cbc3f3be5562e7b488ff0c7247d9bfe52e6))


### Pkgs/tau-tower

- Init at 0-unstable-2025-09-30 - ([e2a5e32](https://github.com/ngi-nix/ngipkgs/commit/e2a5e32c3a893f3c296ffa3a409b7140b4349cce))


### Projects

- *0WM:* Fix dbus session address for test - ([919e62c](https://github.com/ngi-nix/ngipkgs/commit/919e62c3e0ad25f84a9fb1f19cdd694e2c0f1840))
- *Blink:* Enable dummy sound card in test - ([79bb85c](https://github.com/ngi-nix/ngipkgs/commit/79bb85c6965c04a5fe6681dfc268a9cb3422e75e))
- *Blink:* Login with user SIP account in test - ([2032dd9](https://github.com/ngi-nix/ngipkgs/commit/2032dd95a08bea17a3229fced11dc5342b52a63d))
- *Ethersync:* Rename to Teamtype; refactor - ([956be0f](https://github.com/ngi-nix/ngipkgs/commit/956be0f7b97b551245ddbf7b44661574423512db))
- *Marginalia:* Mark as broken - ([3d3e6c7](https://github.com/ngi-nix/ngipkgs/commit/3d3e6c73f968e91dc988a7c5fb4606cee450c2bd))
- *Nominatim:* Fix test dependency - ([fc33d3f](https://github.com/ngi-nix/ngipkgs/commit/fc33d3f177b46f70682bb789500def96735d70bf))
- *Nominatim:* Use tests from Nixpkgs - ([19f2816](https://github.com/ngi-nix/ngipkgs/commit/19f2816c37f0ca75b68c31983b08ec78d0260a7d))
- *SSTorytime:* Init - ([ae9dc65](https://github.com/ngi-nix/ngipkgs/commit/ae9dc6508056db6e2c34649ed60e62428b75a6e0))
- *SSTorytime:* Add options for local database - ([0c1407c](https://github.com/ngi-nix/ngipkgs/commit/0c1407c12759bb6b128902a2552ca4cf504c6d30))


### Projects/Tau

- Init - ([0da1074](https://github.com/ngi-nix/ngipkgs/commit/0da1074c922dd9f2d3114849068f7efe6f34487a))


### Python3Packages.sipsimple

- Pin ffmpeg to version 7 - ([4cec143](https://github.com/ngi-nix/ngipkgs/commit/4cec14340869b82f054c97bbedff1a9fe5d40073))


### Treewide

- Categorize all projects' subgrants - ([6c7d462](https://github.com/ngi-nix/ngipkgs/commit/6c7d462ea83082d7768747ac43682e314170dd14))


## [25.10](https://github.com/ngi-nix/ngipkgs/compare/25.09..25.10) - 2025-11-04

### Bug Fixes

- Trailing whitespace in project template - ([3f350e1](https://github.com/ngi-nix/ngipkgs/commit/3f350e19a4d569a537a9a3adcf6bf94db32ade25))
- Metrics count - ([6f7bc9e](https://github.com/ngi-nix/ngipkgs/commit/6f7bc9ef77e4260852cc1fe3c882f4d4caabd514))


### Documentation

- *overview:* Update usage instructions by demo type - ([acdb686](https://github.com/ngi-nix/ngipkgs/commit/acdb6863f9a61954010514a7f9ac3caf33eb81f0))
- Add header to project reference; refactor & generate - ([6b2b8a7](https://github.com/ngi-nix/ngipkgs/commit/6b2b8a72b4de71cd585ac47fff4e821b638101d7))
- Refactor project template; add demo - ([b3fe3f8](https://github.com/ngi-nix/ngipkgs/commit/b3fe3f8a71a8f35e6a330d55f0b8514fb818be8e))
- Fix url to contributing.md - ([ec880ba](https://github.com/ngi-nix/ngipkgs/commit/ec880ba0cb90074b23d30b01f384400d2c17f824))
- Change example package url - ([06bb816](https://github.com/ngi-nix/ngipkgs/commit/06bb81620b65f6cad4919fc3e2ddce4ca73a351e))
- Register url changed - ([a769671](https://github.com/ngi-nix/ngipkgs/commit/a7696717845581be1511c6d3d701c15a60f581c2))


### Features

- Init changelog for 2025 - ([bb03de9](https://github.com/ngi-nix/ngipkgs/commit/bb03de99bfbba330e87cc8cf3bd444502a60cda5))


### Overview

- Format render-template.py - ([37cd799](https://github.com/ngi-nix/ngipkgs/commit/37cd79995248673ac0ec41aa1fca886b1733aba3))
- Add `unique_id` function to jinja render - ([6e70e28](https://github.com/ngi-nix/ngipkgs/commit/6e70e28a49b13cdc1bc5f0607bc39ca1ed8435d4))
- Update demo instructions - ([c7598e7](https://github.com/ngi-nix/ngipkgs/commit/c7598e77520f67257fd31cb4bdbbadfd9d56ff2c))
- Move some colors to CSS variables - ([68cac57](https://github.com/ngi-nix/ngipkgs/commit/68cac57df4b160d1295c1512386c1cff962e274b))
- Use tabs when shell-instructions is a list - ([5c4d7b6](https://github.com/ngi-nix/ngipkgs/commit/5c4d7b68cf7e0b2c14e6e23026bee8158c924928))
- Add source code declaration link to options - ([dabaf81](https://github.com/ngi-nix/ngipkgs/commit/dabaf818e1099d362613d000d1a09d215a4fcb06))
- Link missing artefacts to their docs sections - ([27c2152](https://github.com/ngi-nix/ngipkgs/commit/27c2152f114f64519b7d81a38349403ec29c0e6a))
- Fix declaration path with flakes - ([3509e13](https://github.com/ngi-nix/ngipkgs/commit/3509e13e464c038cdbb7460ee607fc04b05d45f3))
- Add example files declaration links - ([0715bcc](https://github.com/ngi-nix/ngipkgs/commit/0715bccfdfc57a73943b4301f67a7fac5a82be34))
- Reuse common functions in modules - ([0d51be7](https://github.com/ngi-nix/ngipkgs/commit/0d51be759ac7ede27a90810e1eb063c938dcb43c))
- Add project declaration - ([8ddec21](https://github.com/ngi-nix/ngipkgs/commit/8ddec2119b0335f4be9ddc303d14c1525284dd85))


### Refactor

- Flatten project types; move project up - ([f16164b](https://github.com/ngi-nix/ngipkgs/commit/f16164bfbec1f800d1e265f53bdc8ba0657a4db4))
- Metrics and get more accurate results - ([d20a40d](https://github.com/ngi-nix/ngipkgs/commit/d20a40db9a91889bf0d9e8c55c900bc6f5480cad))


### Anastasis

- Add update script - ([ff9f27b](https://github.com/ngi-nix/ngipkgs/commit/ff9f27b64d9f27a5b1b38fe0e2128adab5a27984))


### Anastasis-gtk

- Add update script - ([88f0cc7](https://github.com/ngi-nix/ngipkgs/commit/88f0cc7b073ea9b28bd26d8b50bfe00139b90c75))


### Bigbluebutton.bbb-freeswitch-core.libwebsockets

- Copy CMake 4 fix from Nixpkgs - ([decfa14](https://github.com/ngi-nix/ngipkgs/commit/decfa14cacf1ed6f59882a93c9ea0b3bf429f577))


### Blink-qt

- Use derivation from Nixpkgs - ([f86fe9c](https://github.com/ngi-nix/ngipkgs/commit/f86fe9c640efaa7a2ffe3f9236285389bcc77fe2))


### Heads.*

- Fix CMake 4 compatibility - ([043918b](https://github.com/ngi-nix/ngipkgs/commit/043918b0cfca672d89c54073bb2a87fbfc35bb31))
- Cut down amount of CI-built qemu boards - ([6360218](https://github.com/ngi-nix/ngipkgs/commit/6360218df8eaecd4dab8ad484e72e8253d236cd7))


### Helium

- 5.1.0 -> 5.1.1 - ([5eb8627](https://github.com/ngi-nix/ngipkgs/commit/5eb8627444342ce800cb38885c080f49bb30ce3c))
- Refactor - ([133868b](https://github.com/ngi-nix/ngipkgs/commit/133868b616b3778047b5ef43f3fea4db2305186c))


### Highctidh

- Use derivation from Nixpkgs - ([ea1ef59](https://github.com/ngi-nix/ngipkgs/commit/ea1ef59f4b59a29245b41e6e5f7febec825227b4))


### Inventaire-client

- Fix build script; refactor - ([f5885e4](https://github.com/ngi-nix/ngipkgs/commit/f5885e467027e5a7f7f73b1070785eb79429393c))


### Inventaire-i18n

- 0-unstable-2025-06-12 -> 0-unstable-2025-10-07 - ([fa7fc40](https://github.com/ngi-nix/ngipkgs/commit/fa7fc40545161151530f775ebbec55e8f4025321))
- Refactor update script - ([e2ce59d](https://github.com/ngi-nix/ngipkgs/commit/e2ce59d68264d72e8fb8fcb4186bf2bfa36480a1))
- 0-unstable-2025-10-07 -> 0-unstable-2025-10-20 - ([8ca7642](https://github.com/ngi-nix/ngipkgs/commit/8ca76422c54364244e80e53ef46038328eae7e70))


### Irdest-lora-firmware

- Init at 0.1.0 - ([a0c6152](https://github.com/ngi-nix/ngipkgs/commit/a0c61524743883dc9d58d9aa923673a9b89c1e70))


### Kazarma

- Fix build failure - ([da8e22f](https://github.com/ngi-nix/ngipkgs/commit/da8e22f25392e223ab5c4d3057f6422dfaab766e))
- Add update script - ([69f1619](https://github.com/ngi-nix/ngipkgs/commit/69f16192a82c749a39c7d605fd485d8e434e2f21))


### Kbin-backend

- 0.0.1 -> 0.0.1-unstable-2024-02-05; add update script - ([bf4b61f](https://github.com/ngi-nix/ngipkgs/commit/bf4b61f5ab1571ff6d708dcd2c2ed9056f6fdd82))
- Refactor derivation - ([8b776ec](https://github.com/ngi-nix/ngipkgs/commit/8b776ec50729dc834af9f17c3e321e1ffa287a43))


### Kbin-frontend

- 0.0.1 -> 0.0.1-unstable-2024-02-05 - ([10e1968](https://github.com/ngi-nix/ngipkgs/commit/10e1968740a07bea37696a095f8abd0451f85b85))


### Makemake

- Migrate from deprecated `authType` - ([1e3a865](https://github.com/ngi-nix/ngipkgs/commit/1e3a865249a1c6bd24842f702e8d36d8a9217566))


### Meta-press

- Use fetchFromGitLab - ([362bec9](https://github.com/ngi-nix/ngipkgs/commit/362bec987b7d5c8139a530e5a2fb3de9c0d41ddb))
- 1.8.17.4 -> 1.9.1 - ([bdc34ba](https://github.com/ngi-nix/ngipkgs/commit/bdc34ba0fd4b9df12405a19a57464d3603dec65a))


### Nodebb

- Add update script - ([4593328](https://github.com/ngi-nix/ngipkgs/commit/459332850ace7f7812953c89850b80275effb94e))
- 4.4.3 -> 4.6.0 - ([d565fe1](https://github.com/ngi-nix/ngipkgs/commit/d565fe107a66ed927051ed19310268c306599035))


### Openfire

- 4.9.2 -> 5.0.2 - ([52c9ef7](https://github.com/ngi-nix/ngipkgs/commit/52c9ef70585f82d8b4992cf41d8604ee8f1eb715))


### Openxc7

- Add update script; fix build - ([206cb24](https://github.com/ngi-nix/ngipkgs/commit/206cb24fe9aea95b6e70f7b6d249063dc922fcbd))


### Pagedjs-cli

- 0.4.3-unstable-2024-05-31 -> 0-unstable-2024-05-31 - ([2f719c6](https://github.com/ngi-nix/ngipkgs/commit/2f719c6d98b92a30cd8b6c2e4e7a6ef1c9ddc19a))


### Pkgs

- *repath-studio:* Fix maven deps outputHash - ([b2b963b](https://github.com/ngi-nix/ngipkgs/commit/b2b963b1e6768626c073e950f41d784b3ce04131))
- Add overlays.nix for fixes - ([1f9814c](https://github.com/ngi-nix/ngipkgs/commit/1f9814c02c97cd2b81e1317ecc2827db4d72cfaa))


### Pkgs/_0wm-ap-mock

- Init at 0-unstable-2025-10-27 - ([bd3bbcc](https://github.com/ngi-nix/ngipkgs/commit/bd3bbcc5774194bd858ce26d06965a0011c3a4ea))


### Pkgs/_0wm-client

- Init at 0-unstable-2025-10-06 - ([2b23dd1](https://github.com/ngi-nix/ngipkgs/commit/2b23dd1541325e516d7c8253319c0f19ebc136af))


### Pkgs/_0wm-opmode

- Init at 0-unstable-2025-09-23 - ([895e5f9](https://github.com/ngi-nix/ngipkgs/commit/895e5f9490cb57174ddf00c0f0389fc4909014f4))


### Pkgs/_0wm-server

- Init at 0-unstable-2025-09-23 - ([ddaa7cd](https://github.com/ngi-nix/ngipkgs/commit/ddaa7cdc34a7bec10f63f383e37a44bf1aa3d5da))


### Pkgs/ratman

- Use buildNpmPackage for dashboard - ([5df9f14](https://github.com/ngi-nix/ngipkgs/commit/5df9f144306efc609862a58e32576ac3ec09261d))


### Pkgs/{libgnunetchat,gnunet-messenger-cli}

- Remove - ([e764d3b](https://github.com/ngi-nix/ngipkgs/commit/e764d3b300a6b78d71f30075f2bb989c069a7886))


### Project

- *owasp:* Remove upstreamed tests depscan.nix, blint.nix - ([c08f70e](https://github.com/ngi-nix/ngipkgs/commit/c08f70e12ac53930e4631f56f8780a487ac5eb51))


### Projects

- *Irdest:* Refactor config & test; add verbosity - ([58469b8](https://github.com/ngi-nix/ngipkgs/commit/58469b81bcdbab60e90710979167eb316d9b8bf9))
- *Irdest:* Mark demo test as broken - ([8349af3](https://github.com/ngi-nix/ngipkgs/commit/8349af3b6299b4ed3fbef7787e04ef717f7e9f09))
- *pagedjs:* Fix docs links - ([ec5d3bc](https://github.com/ngi-nix/ngipkgs/commit/ec5d3bc8f1b830256858e4a671daa1dadb375c93))
- *repath-studio:* Fix docs link - ([e95cfb9](https://github.com/ngi-nix/ngipkgs/commit/e95cfb94d47f96b3e2cdb8670b8bb7ded58a5536))
- *wax:* Remove docs link - ([337ada0](https://github.com/ngi-nix/ngipkgs/commit/337ada07c8185c7843fdb8a7cc5cb0a0758948c8))


### Projects/0WM

- Init - ([31f512f](https://github.com/ngi-nix/ngipkgs/commit/31f512fb4a7a4e9e112e937ddaf351e0a72f4498))


### Projects/Blink

- Migrate usage instructions - ([0c3240a](https://github.com/ngi-nix/ngipkgs/commit/0c3240a00ba5f869f6a328e84d551f235262afd3))


### Projects/Ethersync

- Migrate usage instructions - ([9733137](https://github.com/ngi-nix/ngipkgs/commit/9733137171c7d9564ab9a801c8e4d685c3463817))


### Projects/Galene

- Mark stream test as broken - ([45f1661](https://github.com/ngi-nix/ngipkgs/commit/45f16613865ba9cc9e4578f518f1a33051f54069))
- Migrate usage instructions - ([1f00a73](https://github.com/ngi-nix/ngipkgs/commit/1f00a7315afb77c2f6522d4f3e1c84e8ae8f0d1b))


### Projects/Irdest

- Refactor and fix test - ([b35c2d9](https://github.com/ngi-nix/ngipkgs/commit/b35c2d936115b2467ff954e9baaf871a7dbbd554))
- Work around ratmand config failure - ([6a48957](https://github.com/ngi-nix/ngipkgs/commit/6a4895768a679b2781119a953aee3ca509272488))


### Projects/Kaidan

- Migrate usage instructions - ([b954daa](https://github.com/ngi-nix/ngipkgs/commit/b954daa8ba51a32ee9643559410c0d96483507b5))


### Projects/Kazarma

- Mark test and derivation as broken - ([ccda92b](https://github.com/ngi-nix/ngipkgs/commit/ccda92b3d70011fe1301e296dc6afef289128304))


### Projects/Nominatim

- Migrate usage instructions - ([d8df8fd](https://github.com/ngi-nix/ngipkgs/commit/d8df8fdb905f090c67067bab8973541ed499e70f))


### Projects/PagedJS

- Migrate usage instructions - ([cca910f](https://github.com/ngi-nix/ngipkgs/commit/cca910fd57bb28db26905ee86222b3b08144c772))


### Projects/PeerTube

- Migrate usage instructions - ([4d78d6a](https://github.com/ngi-nix/ngipkgs/commit/4d78d6a21732376372b40958879fca8155c09ae5))


### Projects/ReOxide

- Add program module - ([bbc56eb](https://github.com/ngi-nix/ngipkgs/commit/bbc56eb2bbb6e475f7332eb80bdd66ba0f068cb9))
- Add service module - ([163ea1a](https://github.com/ngi-nix/ngipkgs/commit/163ea1a35d138074406fefedc0f0175b039212f9))
- Init program and service modules - ([7a2b52d](https://github.com/ngi-nix/ngipkgs/commit/7a2b52d288337a78c802c4559238b14acd895ddf))
- Add VM test - ([8733104](https://github.com/ngi-nix/ngipkgs/commit/8733104e9d54cae0509b51ba0b103e54b697fd78))
- Add service and program examples - ([d9309f6](https://github.com/ngi-nix/ngipkgs/commit/d9309f6a24a73d091063ddbb998dda207590fde7))


### Projects/ntpd-rs

- Migrate usage instructions - ([05cdd7f](https://github.com/ngi-nix/ngipkgs/commit/05cdd7f1314dc1855de146355956ae3cca072398))


### Projects/oku

- Migrate usage instructions - ([d6e7b72](https://github.com/ngi-nix/ngipkgs/commit/d6e7b72defe9737ce33f485566a5cf8196dd11a9))


### Projects/owasp

- Migrate usage instructions - ([f9fb3a0](https://github.com/ngi-nix/ngipkgs/commit/f9fb3a0fb4485ad324eea93a75da24a43fc2749a))


### Projects/repath-studio

- Init - ([ad9a77a](https://github.com/ngi-nix/ngipkgs/commit/ad9a77a45aee7b6b80e4d50a8aba12952ff6eb58))


### Projects/xrsh

- Migrate usage instructions - ([64d3014](https://github.com/ngi-nix/ngipkgs/commit/64d3014869e42fe0ab4a480a67b715eb75ca1181))


### Projects/y-crdt

- Init - ([e88b00a](https://github.com/ngi-nix/ngipkgs/commit/e88b00ab64610192a2b749544a50e3d8e3c11a78))


### Proximity-matcher

- Add update script - ([85c4ceb](https://github.com/ngi-nix/ngipkgs/commit/85c4cebe7e9bbea32a7763f8a7da8d5c3d2886c8))


### Ratman

- 0.7.0 -> 0.7.0-unstable-2025-09-09; add update script - ([1334633](https://github.com/ngi-nix/ngipkgs/commit/133463376bd13f3dd0fd713452bf84e89181d672))


### Reoxide-plugin-simple

- Add update script; fix version - ([0f2068d](https://github.com/ngi-nix/ngipkgs/commit/0f2068df5db4308b602a412838c189598d79ea92))


### Repath-studio

- Init at 0.4.10 - ([76a8ca8](https://github.com/ngi-nix/ngipkgs/commit/76a8ca85bc31d5e3bd2d290ac0c29dd4928d1b3b))


### Steamworks-pulleyback

- 0.3.0 -> 0.3.0-unstable-2021-08-16 - ([b57ef16](https://github.com/ngi-nix/ngipkgs/commit/b57ef1653804f97b4bb092e19ab3f87041879ad9))


### Taldir

- Add update script - ([ea3d243](https://github.com/ngi-nix/ngipkgs/commit/ea3d243c815dc0882694120f596ebddc0d3f2fe6))
- 1.0.5 -> 1.0.5-unstable-2025-10-15; refactor update script - ([7df7b5b](https://github.com/ngi-nix/ngipkgs/commit/7df7b5b7c17d51b7a15f4a3ca9f885f6897fae54))


### Taler-mdb

- Add update script - ([020d03c](https://github.com/ngi-nix/ngipkgs/commit/020d03ceb0def862f3fb61028849dfdd98f2e6e4))
- 0.14.1 -> 1.0.0 - ([c50510f](https://github.com/ngi-nix/ngipkgs/commit/c50510f59d284c4aefc9f98bf71076c419e32ffc))


### Templates

- Add label to project template - ([f58c5b9](https://github.com/ngi-nix/ngipkgs/commit/f58c5b94db380c67ffc5513a36fcd68c073df682))


### Treewide

- Categorize subgrants - ([928e00d](https://github.com/ngi-nix/ngipkgs/commit/928e00d8adff2d65b322de302e395233ff255d59))


### Types

- Make usage-instructions nullOr - ([2a19fd0](https://github.com/ngi-nix/ngipkgs/commit/2a19fd01633e828a237da9ced8e086b629e3a6e2))


### Verso

- 0-unstable-2025-06-15 -> 0-unstable-2025-06-17 - ([be5b1b8](https://github.com/ngi-nix/ngipkgs/commit/be5b1b8237b07fa1fcdba3bfc0c532a1b5ea0f0a))


### Vula

- Refactor; move hkdf to the same dir - ([a8b221d](https://github.com/ngi-nix/ngipkgs/commit/a8b221dc5efd2cc9f3a87a1a12e24d342b008619))
- Add update script; update to latest version - ([23c361b](https://github.com/ngi-nix/ngipkgs/commit/23c361bde760164b7946059d9e62a02308d5868c))


### Wax-client

- 0-unstable-2025-08-14 -> 0-unstable-2025-10-07 - ([f7b31b7](https://github.com/ngi-nix/ngipkgs/commit/f7b31b75121e1fb660d578136a10e144d7aac266))


### Wax-server

- 0-unstable-2025-08-14 -> 0-unstable-2025-10-07 - ([399ef12](https://github.com/ngi-nix/ngipkgs/commit/399ef12384232511203fff62c9310742f14bc201))


### Wireguard-rs

- Add update script - ([d141790](https://github.com/ngi-nix/ngipkgs/commit/d141790a4256d2219832abf11924f4a899427bcf))


## [25.09](https://github.com/ngi-nix/ngipkgs/compare/25.08..25.09) - 2025-09-24

### CI/CD

- Remove ubuntu 24.10 - ([8f5b5d5](https://github.com/ngi-nix/ngipkgs/commit/8f5b5d52721407278e4e24e3382f6e35e6c4bfa2))
- Use cachix/install-nix-action - ([d422e66](https://github.com/ngi-nix/ngipkgs/commit/d422e66a4aa05e7d584c5eac2574fdd5e4ba80f7))
- Enable flakes and nix-command in makemake workflow - ([1b19ab7](https://github.com/ngi-nix/ngipkgs/commit/1b19ab75f2f37154001da65732049f3bde75eca6))
- Improve security - ([69d868d](https://github.com/ngi-nix/ngipkgs/commit/69d868dc337fb8e40f896eb3108f9ffc9cd99395))


### Documentation

- Document project types - ([dd2ed94](https://github.com/ngi-nix/ngipkgs/commit/dd2ed9428faf68641601dae3be930da99fc72a82))


### Features

- Add mandatory metadata links - ([be45c10](https://github.com/ngi-nix/ngipkgs/commit/be45c10e324a5ccf9354f33c5703267f6ab25921))


### Libervia

- Re-enable & fix tests - ([68a9682](https://github.com/ngi-nix/ngipkgs/commit/68a96828b4d7c9ecdf1bc2b9230152540a04a7ac))
- Add VM demo - ([8a49426](https://github.com/ngi-nix/ngipkgs/commit/8a4942627b6070f7ffb03412109ef55d5b0ca7e3))


### Overview

- Only run deployment on ngi-nix/ngipkgs - ([8922b5e](https://github.com/ngi-nix/ngipkgs/commit/8922b5ee1c02e6be84d17fe11122058cf515eea9))


### Refactor

- Move custom lib to a separate file - ([e0cc56f](https://github.com/ngi-nix/ngipkgs/commit/e0cc56f29f421b402e5b970975a56b946e6f0ba7))
- Project composition; reorder attributes - ([167b86a](https://github.com/ngi-nix/ngipkgs/commit/167b86ae563f97a43b473352317847b0bf5872a9))


### Bigbluebutton

- Turn into package scope, split packages into individual files - ([7f4ce40](https://github.com/ngi-nix/ngipkgs/commit/7f4ce409be0a69a76a06ee87debef7b0461328cf))
- Put mkSbtDerivation into callPackage scope - ([d840f95](https://github.com/ngi-nix/ngipkgs/commit/d840f95856b0fbc50f62c01b05d118b7049a4cdf))
- Make more things shared across packages - ([0431af2](https://github.com/ngi-nix/ngipkgs/commit/0431af2b86758e2a8200af2b6dacc1fb9c7925b9))


### Bigbluebutton.bbb-apps-akka

- Use lndir for symlinking deps - ([6064531](https://github.com/ngi-nix/ngipkgs/commit/6064531c68fef9a30cd4ea3e0c3bd5205210fc1d))


### Bigbluebutton.bbb-config

- Init at 3.0.10-bigbluebutton - ([cde4556](https://github.com/ngi-nix/ngipkgs/commit/cde45567be8013c723c3d6f9da66d6e058d32fc0))


### Bigbluebutton.bbb-etherpad

- Init at 3.0.10-bigbluebutton - ([94f9feb](https://github.com/ngi-nix/ngipkgs/commit/94f9feb3d8a11b635605762055de294ff36c1ff9))


### Bigbluebutton.bbb-freeswitch-core

- Init at 3.0.10-bigbluebutton - ([1a033cc](https://github.com/ngi-nix/ngipkgs/commit/1a033cc467a5a084166020af7d16bd825edb644a))


### Bigbluebutton.bbb-freeswitch-sounds

- Init at 3.0.10-bigbluebutton - ([4e1ec22](https://github.com/ngi-nix/ngipkgs/commit/4e1ec229bb5ad9804e049e93816c6c925ea6a921))


### Bigbluebutton.bbb-fsesl-akka

- Init at 3.0.10-bigbluebutton - ([022b2dd](https://github.com/ngi-nix/ngipkgs/commit/022b2dd9cb9050f6b550f53e1da01ae3ebf25ae3))


### Bigbluebutton.bbb-fsesl-client

- Init at 3.0.10-bigbluebutton - ([3765e59](https://github.com/ngi-nix/ngipkgs/commit/3765e5932e5a9a1271038abde4f39f34d37c885e))


### Flake

- Use the refactoring branch of buildbot-nix - ([402c400](https://github.com/ngi-nix/ngipkgs/commit/402c40005c9157eec2b9f1d2ff70a62704734e98))
- Follow main again on buildbot-nix - ([dab6b51](https://github.com/ngi-nix/ngipkgs/commit/dab6b518597ef3dfcf588bbac59f9611eee4354e))


### Infra

- Remove terraform files for abandoned infra - ([7e7e98c](https://github.com/ngi-nix/ngipkgs/commit/7e7e98cf5548a6db275cc00e6c2dc12ab832e976))


### Libervia-backend

- Unbreak - ([9b383dd](https://github.com/ngi-nix/ngipkgs/commit/9b383dd2230961fb7c313707693a7380a49ae441))


### Libervia-desktop-kivy

- Unbreak - ([62d0c82](https://github.com/ngi-nix/ngipkgs/commit/62d0c8298d437f30e49fa8992441380e451fff02))


### Libervia-media

- Unbreak - ([1088f57](https://github.com/ngi-nix/ngipkgs/commit/1088f5717414166b66959ac72ccaa3bff1970a02))


### Pkgs/kip

- Fix build - ([fc55435](https://github.com/ngi-nix/ngipkgs/commit/fc5543525ebb48e9058b51a2e64ca6c2f574a2f8))


### Pkgs/ratman

- Init at 0-unstable-2025-08-24 - ([b62478c](https://github.com/ngi-nix/ngipkgs/commit/b62478c9eb30bd275dadb69ce284ac3a76f4cc6b))
- 0-unstable-2025-08-24 -> 0-unstable-2025-09-14 - ([f575f89](https://github.com/ngi-nix/ngipkgs/commit/f575f89bf561326170734f29e5122c5c64f339f1))
- Refactor - ([f10843a](https://github.com/ngi-nix/ngipkgs/commit/f10843abbc6691fe46d5624c3a0498bc90b40d83))


### Pkgs/steamworks

- Remove - ([d499c75](https://github.com/ngi-nix/ngipkgs/commit/d499c7597159643d7fffa4f43a41857c486b6566))


### Pkgs/steamworks-pulleyback

- Add openssl; refactor - ([333d738](https://github.com/ngi-nix/ngipkgs/commit/333d7388e177a3ae19042ef71a688907323ff48c))


### Pkgs/tlspool

- Fix and modernize - ([3b02733](https://github.com/ngi-nix/ngipkgs/commit/3b0273388f3a67a07f085ab8e5c928f35156a80a))


### Pkgs/verso

- Unpin llvmPackages - ([b16aad7](https://github.com/ngi-nix/ngipkgs/commit/b16aad7af812512a403fffcba659d9965299c0b3))


### Projects

- Batch add mandatory links; refactor subgrants - ([f4e08e6](https://github.com/ngi-nix/ngipkgs/commit/f4e08e6f1f01d881d6b7246cb39a9a21d629a081))


### Projects/ERIS

- Mark as broken - ([a9caf3d](https://github.com/ngi-nix/ngipkgs/commit/a9caf3d83dd978381cf7f576b32ac6050ffd81dc))


### Projects/Irdest

- Improve metadata - ([5ef3481](https://github.com/ngi-nix/ngipkgs/commit/5ef3481b52c2b1c90a5a565ee36e853a38a7c890))
- Init ratmand module - ([73cebd3](https://github.com/ngi-nix/ngipkgs/commit/73cebd32162c4ead6bfb56aea6cec784973b86f0))
- Add missing deliverables info - ([8ca338c](https://github.com/ngi-nix/ngipkgs/commit/8ca338c62c110f4a79431d276e39bbc1f1e57241))
- Init demo - ([9df2ba3](https://github.com/ngi-nix/ngipkgs/commit/9df2ba36ec18e2218e3436fa35d21a8465ec2b5c))
- Properly wait for API in tests - ([f2387d1](https://github.com/ngi-nix/ngipkgs/commit/f2387d1efd493c5abaa94e169dd3fd25a4bfa76b))
- Adjust service restart times - ([6e93329](https://github.com/ngi-nix/ngipkgs/commit/6e93329d16adaa61fe757706c4fd68556942d02f))


### Projects/Servo

- Mark test as broken - ([1de6b05](https://github.com/ngi-nix/ngipkgs/commit/1de6b05dfd632cda7f39436c69cfb31b59d2a04f))


### Projects/ThresholdOPRF

- Init ([#1621](https://github.com/ngi-nix/ngipkgs/issues/1621)) - ([f253c41](https://github.com/ngi-nix/ngipkgs/commit/f253c414a9b87e47e8949f437a03b661f8157e6f))


### Projects/owasp

- Mark test as broken - ([e4893d3](https://github.com/ngi-nix/ngipkgs/commit/e4893d321d4d782b290af98e349a97b17d0e1f3a))


### Projects/slipshow

- Migrate to upstream test - ([0838dda](https://github.com/ngi-nix/ngipkgs/commit/0838dda46ded2d959823bcbdd61b8c2349c0739e))


### Projects/xrsh

- Fix eval warning - ([f0a0267](https://github.com/ngi-nix/ngipkgs/commit/f0a02674f770ccad55b1fe8a766ed5eece36d136))


### Reoxide

- Init at 0.7.0 - ([72e0a6a](https://github.com/ngi-nix/ngipkgs/commit/72e0a6a4c7621a8aac624f7ed102e5c95753273e))


### Reoxide-plugin-simple

- Init 0-unstable-2025-09-12 - ([2e7da4a](https://github.com/ngi-nix/ngipkgs/commit/2e7da4a76a687130c282ed3d63d7ad7bad3facf8))


### Wax-server

- Init at 0-unstable-2025-08-14 - ([e23933b](https://github.com/ngi-nix/ngipkgs/commit/e23933b384c33e6ff05a9f1d9acf66ad7c9912c3))


### Workflows/makemake

- Only run on ngi-nix/ngipkgs - ([720d0c6](https://github.com/ngi-nix/ngipkgs/commit/720d0c61eaa94f0a37003351689b7441687a94f9))


### Workflows/update

- Only run on ngi-nix/ngipkgs - ([8a029e2](https://github.com/ngi-nix/ngipkgs/commit/8a029e21f8a7b6cf61d9d0ba778f55d796cbeb44))


## [25.08](https://github.com/ngi-nix/ngipkgs/compare/25.07..25.08) - 2025-08-29

### Bug Fixes

- Demo tests not being exposed - ([ea2cf5a](https://github.com/ngi-nix/ngipkgs/commit/ea2cf5ab46742a4d0c69d98db5d5ddc055a1f330))


### CI/CD

- Target debian 13 instead of 12 - ([640405f](https://github.com/ngi-nix/ngipkgs/commit/640405fc672f047ea00b64b83760fa41ea3719f0))


### Cryptpad

- Add example - ([af73386](https://github.com/ngi-nix/ngipkgs/commit/af733863cf7199dbd09bd0c7a9865ca18b33645a))


### Ethersync

- Use vimPlugins.ethersync; enable vscode - ([f53f6eb](https://github.com/ngi-nix/ngipkgs/commit/f53f6eb426e03fa2dea65d68bf66f9f5acd5057f))
- Add example; update test and usage - ([174b2c7](https://github.com/ngi-nix/ngipkgs/commit/174b2c7c78124f1d86488de6250ad8dded9a0be4))
- Mark test as broken - ([432fef0](https://github.com/ngi-nix/ngipkgs/commit/432fef0ae71812dd8885b2a3a881ab8ceebf1426))


### Inventaire

- Unbreak test - ([f085624](https://github.com/ngi-nix/ngipkgs/commit/f08562475266dce36e4602b915455bb246abeb26))


### Kaidan

- Mark test as broken - ([e9d7baf](https://github.com/ngi-nix/ngipkgs/commit/e9d7baff65465575483daae085b8f31f9e901b72))
- Fix deprecated option; refactor user setup - ([fac257d](https://github.com/ngi-nix/ngipkgs/commit/fac257dcd415a2d17ded4cdd7c7e94a94cc5b27d))
- Separate demo utils from config - ([f4cef85](https://github.com/ngi-nix/ngipkgs/commit/f4cef85145ef2b470bb986b24d0676d8143c02fe))


### Libervia

- Mark test as broken - ([7fcdef3](https://github.com/ngi-nix/ngipkgs/commit/7fcdef3ed9e3e3636ae669e82d03d7266798ffe1))


### Overview

- Link deliverable label to option anchor - ([f0b5c5c](https://github.com/ngi-nix/ngipkgs/commit/f0b5c5c1d55e8d860c1e8296cc2f128dbc815df5))
- Auto open target element on page load - ([f7846f7](https://github.com/ngi-nix/ngipkgs/commit/f7846f71e96aa096ab3b31567b9e4e418a2d5203))
- Add style for option list and alert - ([d90b70c](https://github.com/ngi-nix/ngipkgs/commit/d90b70cc1fd2cebd9d7958f3e52efc2441fdaa49))
- Add navigation breadcrumbs - ([e71c2e2](https://github.com/ngi-nix/ngipkgs/commit/e71c2e2d3711ce4f523ec278dffb3c72e00072f9))
- Extend pkgs with ngipkgs overlay - ([2adfddb](https://github.com/ngi-nix/ngipkgs/commit/2adfddbdd6782aa5565c4186602c812869ce3493))
- Link to docs for adding demos - ([4e008ab](https://github.com/ngi-nix/ngipkgs/commit/4e008ab71297329a7d1dbde12bce7f8f1b96bbc5))
- Render non-list subgrants - ([27118cb](https://github.com/ngi-nix/ngipkgs/commit/27118cbc2f062eeeb1fcb8a09dab3278029b9a59))
- Add overview-instructions - ([10d3ff9](https://github.com/ngi-nix/ngipkgs/commit/10d3ff936a36c6f34959c5da397a06adb9745049))


### Project/pagedjs

- Implement program and example ([#1498](https://github.com/ngi-nix/ngipkgs/issues/1498)) - ([d3296c2](https://github.com/ngi-nix/ngipkgs/commit/d3296c2a7e549e123de5a9978c592262522b8307))


### Demo

- Modify greet message - ([e5c6eb9](https://github.com/ngi-nix/ngipkgs/commit/e5c6eb96cb346ec69bdc8b233947aab691b648f2))


### Demo-vm

- Handle graphics better - ([6b351a4](https://github.com/ngi-nix/ngipkgs/commit/6b351a4956f0e5bf03d039b5185e88214c4823fa))


### Heads

- Rework board enablement, add more boards - ([6fd4967](https://github.com/ngi-nix/ngipkgs/commit/6fd4967bcc98cf1a52fdb667e2d8ddf453c7aa8d))
- Add more boards that build, add more support for further boards - ([03c18cb](https://github.com/ngi-nix/ngipkgs/commit/03c18cb22ed6718f0f9d18b9622687349ce79836))
- Add Librem targets - ([b9fad77](https://github.com/ngi-nix/ngipkgs/commit/b9fad774569b3a4b44836b7375437781a0010ebb))
- Assert that specified board actually exists - ([364c9de](https://github.com/ngi-nix/ngipkgs/commit/364c9dec91b34de278ecb2980c663b38d0f0742b))


### Makemake

- Show full traces on failed builds - ([62d90d9](https://github.com/ngi-nix/ngipkgs/commit/62d90d9dfc99acdfe384730f6ab34839271007f3))


### Pagedjs-cli

- Init at 0.4.3-unstable-2024-05-31 - ([737df3e](https://github.com/ngi-nix/ngipkgs/commit/737df3edd261b5f2c930645929f2fa273b3292b3))


### Pkgs/kazarma

- Init at 1.0.0-alpha.1-unstable-2025-06-30 - ([1427f78](https://github.com/ngi-nix/ngipkgs/commit/1427f78bd4b7b18a4b6091642ad8d53e307d49f6))


### Programs/holo

- Remove package expression - ([e5234fc](https://github.com/ngi-nix/ngipkgs/commit/e5234fc4889a8b7c21c78a345c4900083772ec31))


### Project/Kaidan

- Abstract graphics config - ([52afe21](https://github.com/ngi-nix/ngipkgs/commit/52afe218b719ab5259747b08fc1b3e8eb69500a8))


### Projects/Aerogramme

- Clean up project - ([57440e5](https://github.com/ngi-nix/ngipkgs/commit/57440e5907de1f7e846acbb3edbe8cb0980b4dd2))
- Add service module example - ([85d2319](https://github.com/ngi-nix/ngipkgs/commit/85d23196b4fc2f55294361e4f85a45a0474f6819))


### Projects/Kaidan

- Add demo vm - ([0602cb5](https://github.com/ngi-nix/ngipkgs/commit/0602cb51234dd39a36e6465e4dd5090cc61fbd8f))
- Disable demo module by default - ([537bbc6](https://github.com/ngi-nix/ngipkgs/commit/537bbc63f6f2a45fff3dfa5a776700e54db93079))


### Projects/Kazarma

- Init - ([0fcd37a](https://github.com/ngi-nix/ngipkgs/commit/0fcd37aefef7699bd15061fd0daae7aa2e4f24c9))


### Projects/Nitrokey

- Add commons subgrants; refactor - ([151e02d](https://github.com/ngi-nix/ngipkgs/commit/151e02d999864d68d3adf6a92d65ed6616155c96))


### Projects/Omnom

- Expose tests - ([cef110c](https://github.com/ngi-nix/ngipkgs/commit/cef110c03ecd1f719161ff575e4b6149bd385e10))


### Projects/PagedJS

- Implement demo example - ([795a971](https://github.com/ngi-nix/ngipkgs/commit/795a971491ea94394149d4f7d7b958db3ae51186))
- Implement VM test - ([792ba23](https://github.com/ngi-nix/ngipkgs/commit/792ba2382a0ff565970e05f7a1921c2e51379691))


### Projects/PeerTube

- Adjust web UI when plugins are managed with Nix - ([b854004](https://github.com/ngi-nix/ngipkgs/commit/b8540045acdc73857aa44e727d0e7475248be7f8))
- Add peertube-runner service - ([c965815](https://github.com/ngi-nix/ngipkgs/commit/c965815880b8d17ec84a00152abe7512c74036bb))


### Projects/ReOxide

- Implement metadata - ([c99d5ae](https://github.com/ngi-nix/ngipkgs/commit/c99d5ae46fefa36a1161ea534dd3895cd2cb1dd0))


### Projects/Wax

- Implement metadata - ([e3916f7](https://github.com/ngi-nix/ngipkgs/commit/e3916f70ae0ad34a1af6405b772cf24dee8b4baf))


### Projects/mitmproxy

- Expose tests - ([6f5e43d](https://github.com/ngi-nix/ngipkgs/commit/6f5e43d0dfe8f07675c0d25669a90881dd922acf))
- Add mitmproxy2swagger - ([bd4d85b](https://github.com/ngi-nix/ngipkgs/commit/bd4d85b828a3130a4dad02f746e4b38a18447c89))
- Fix typo - ([d7d87b5](https://github.com/ngi-nix/ngipkgs/commit/d7d87b537ac755030aa359aa7515f779f78f2651))


### Projects/ntpd-rs

- Add examples and tests - ([4b7f6c9](https://github.com/ngi-nix/ngipkgs/commit/4b7f6c99bcfb67f9b507cfb46231722711593b0e))


### Projects/oku

- Init - ([ebb24e3](https://github.com/ngi-nix/ngipkgs/commit/ebb24e3e6659572b1cc7f492f47328d64d80d355))


### Projects/owasp

- Add depscan test - ([e949345](https://github.com/ngi-nix/ngipkgs/commit/e94934562ea92b0205dc922a8a7d2f44e74db2d8))
- Switch to upstream tests - ([d2f7487](https://github.com/ngi-nix/ngipkgs/commit/d2f7487450420b0684a3a79d5bb14dcfd8b0a567))


### Projects/owi

- Add demo-shell to module.nix - ([f8b0e48](https://github.com/ngi-nix/ngipkgs/commit/f8b0e486cb84373db744aaecd2ab1a39285c873f))


### Projects/verso

- Init - ([204cb8b](https://github.com/ngi-nix/ngipkgs/commit/204cb8b9252161d4a25b9e970164901ff56998fa))


### Treewide

- Split demo configs to a separate module - ([9d9c6b1](https://github.com/ngi-nix/ngipkgs/commit/9d9c6b1f07c058cf1530807abdac49408fcd5170))


### Verso

- Init at 0-unstable-2025-06-15 - ([dbebf40](https://github.com/ngi-nix/ngipkgs/commit/dbebf404fe4624b9be73c3cab1383d8b829f05e2))


### Wax-client

- Init at 0-unstable-2025-08-14 - ([a426785](https://github.com/ngi-nix/ngipkgs/commit/a426785c9b9586ee394ba5990f6cd6c11e6bd0ed))


## [25.07](https://github.com/ngi-nix/ngipkgs/compare/25.06..25.07) - 2025-07-31

### .editorconfig

- Ignore .url files - ([9bf8d8c](https://github.com/ngi-nix/ngipkgs/commit/9bf8d8c553e43255d11763c397237898220476d3))


### .git-blame-ignore-revs

- Add nixfmt 1.0.0 reformat commit - ([97d7f2a](https://github.com/ngi-nix/ngipkgs/commit/97d7f2a85b79b8b07b3b556f7317976a1781a58d))


### .github/ISSUE_TEMPLATE

- Add demo usage instruction template - ([973547c](https://github.com/ngi-nix/ngipkgs/commit/973547cc8e6a140f660104adb60f76180c9ec039))


### Blink

- Add metadata, module, example and VM test - ([2d82e07](https://github.com/ngi-nix/ngipkgs/commit/2d82e0752c90ea133c043c86caef4ac69ad58201))
- Add demo shell - ([1a4f65a](https://github.com/ngi-nix/ngipkgs/commit/1a4f65a9b8dc85b15437303f8b5b2f6a94801d71))


### Documentation

- Add contributor guide on adding examples ([#1244](https://github.com/ngi-nix/ngipkgs/issues/1244)) - ([9794e5c](https://github.com/ngi-nix/ngipkgs/commit/9794e5ce32a62f3273229d2e571df2edf810f85d))
- Add workflow for implmeneting a program - ([e5abcc7](https://github.com/ngi-nix/ngipkgs/commit/e5abcc79ce6c7eacdfd60669146a0d38cb24e219))
- Update examples - ([0f6539f](https://github.com/ngi-nix/ngipkgs/commit/0f6539fe28e6f9320713258de95cc8b6e1ce4bc2))


### Flake

- Add sbt-derivation input - ([79e8d09](https://github.com/ngi-nix/ngipkgs/commit/79e8d09ae6629369257e99603b243735c6ac483c))


### Galene

- Extend NixOS module - ([2d9cc52](https://github.com/ngi-nix/ngipkgs/commit/2d9cc52ff6b859a1d2aa04f725525081980a1248))
- Add demo; use NixOS tests - ([a8f0777](https://github.com/ngi-nix/ngipkgs/commit/a8f0777cfed86ca18c72a36d43b0ee7622f33bfa))
- Add description to demo - ([ec47780](https://github.com/ngi-nix/ngipkgs/commit/ec477802ee33459a3878a7e06f4727f1ff461cc2))


### Holo

- Fix holo-cli - ([6fafc31](https://github.com/ngi-nix/ngipkgs/commit/6fafc31d161cc0a8e79bfd9d036e3def5daacefb))
- Add more potential tests for protocols - ([f430d54](https://github.com/ngi-nix/ngipkgs/commit/f430d545d53e1e8d51a55513bb3239f37212c083))


### Inventaire

- Init - ([c9a5925](https://github.com/ngi-nix/ngipkgs/commit/c9a5925d68ab9976a3be9c096714b503af76b82a))
- Open firewall; print ready message in demo - ([0895909](https://github.com/ngi-nix/ngipkgs/commit/089590942bfb894a77d2e9b7437ea90c59ba8b49))
- Set map tile provider in example/demo to OpenStreetMap - ([f0b5ee8](https://github.com/ngi-nix/ngipkgs/commit/f0b5ee85e285bf285827b8dd2b40745698028ec8))


### Overview

- Add button to link examples' docs ([#1280](https://github.com/ngi-nix/ngipkgs/issues/1280)) - ([16692b4](https://github.com/ngi-nix/ngipkgs/commit/16692b4ab4fbf70be91d5ac51cf4de924000b5f5))
- Add code-snippet and demo content-types - ([5278d1a](https://github.com/ngi-nix/ngipkgs/commit/5278d1a2a27c2bfb6cddb6d40f9dff1941c2bbf2))
- Modularize demo instruction - ([5474ca3](https://github.com/ngi-nix/ngipkgs/commit/5474ca3369debde2d09ead73460eab64608cc893))
- Render links to contributing tests and instructions - ([8cffa31](https://github.com/ngi-nix/ngipkgs/commit/8cffa31d21e10b4db82f4a2851789e411eb1fe6b))
- Add content-type for option ([#1288](https://github.com/ngi-nix/ngipkgs/issues/1288)) - ([e2dc5ff](https://github.com/ngi-nix/ngipkgs/commit/e2dc5ff00eaf6a8739b78acfbf9a16c27819a9dd))
- Indicate problems on deliverable tags - ([79ce00f](https://github.com/ngi-nix/ngipkgs/commit/79ce00f21eacc0b586bb037adbff3c0ad40aae7e))
- Fix update script status for scopes - ([c3bf3ff](https://github.com/ngi-nix/ngipkgs/commit/c3bf3ff454ba146c0c4a8da1552ae240de6c74f5))
- Render missing programs/services - ([9f44994](https://github.com/ngi-nix/ngipkgs/commit/9f449944031a0a590a114dd6ee20227533b65a0f))
- Fix demo description access - ([77f4a8c](https://github.com/ngi-nix/ngipkgs/commit/77f4a8c1827a36438fb13ef5d39ea0095be5db5b))
- Refactor option composition - ([2128003](https://github.com/ngi-nix/ngipkgs/commit/2128003f7c325f57579dd6378e924cad795e167d))
- Use example attribute name as title - ([c18f969](https://github.com/ngi-nix/ngipkgs/commit/c18f969398f0b858f80f7dc5b5c48840be65ba8b))
- Use top margin in example button - ([b9c949e](https://github.com/ngi-nix/ngipkgs/commit/b9c949e533cf53a5565a7ef341c5dd928fcd64b3))
- Fix download button - ([c068c7e](https://github.com/ngi-nix/ngipkgs/commit/c068c7ef1a13637d4fcea1a321c1f7107a153051))
- Refactor demoFile - ([0e36991](https://github.com/ngi-nix/ngipkgs/commit/0e36991107ca0635a092404f75fd107db7399c25))
- Show demo instructions using markdown - ([dafb047](https://github.com/ngi-nix/ngipkgs/commit/dafb0479ea6fc3dcfe75fc6ba18f41ca1940a81c))


### Refactor

- Project evaluation checking - ([a28abeb](https://github.com/ngi-nix/ngipkgs/commit/a28abeb1db68f532b32bdd4cf485f56719c18019))


### Taler

- Remove program; cleanup - ([50703e6](https://github.com/ngi-nix/ngipkgs/commit/50703e6091f36081165359e8e19c8760ab1a6cae))


### Bigbluebutton.{bbb-common-message,bbb-apps-akka}

- Init at 3.0.10-bigbluebutton - ([8b5e99e](https://github.com/ngi-nix/ngipkgs/commit/8b5e99e6ca4b9ff8e83ab9542911e1a65b390108))


### Blink-qt

- Init at 6.0.4 - ([2869d58](https://github.com/ngi-nix/ngipkgs/commit/2869d58597322d45d1aa25e33a698d5df9d8f338))


### Contributing

- Recommend using upstream module examples - ([785bd07](https://github.com/ngi-nix/ngipkgs/commit/785bd07b95a86f8130a37b2fe6af15daaa0a6975))


### Demo

- Add demo option - ([6ce69e8](https://github.com/ngi-nix/ngipkgs/commit/6ce69e83249f372bd71e53c5c09d13e1248b7613))
- Add more disk space for VM demo - ([3e4b931](https://github.com/ngi-nix/ngipkgs/commit/3e4b931195c94586c03436e8b281314ca1c8a2ab))


### Devmode

- Enable verbose output - ([dc5f627](https://github.com/ngi-nix/ngipkgs/commit/dc5f6274de0072ab7425866b83de846bde97a562))


### Ethersync

- Add nix-update-script - ([82c5fe6](https://github.com/ngi-nix/ngipkgs/commit/82c5fe6e9cb8df7a278763a84e8fbdcf75bf497b))
- Add versionCheckHook - ([d33d230](https://github.com/ngi-nix/ngipkgs/commit/d33d2302a84cb9a4d079a42870b8090b0609a80a))
- Remove in favor of nixpkgs ethersync - ([a9dd672](https://github.com/ngi-nix/ngipkgs/commit/a9dd67267ffba2aa89559c87f38ddb53a8aa45b9))


### Heads

- Improve updateDepsScript ([#1293](https://github.com/ngi-nix/ngipkgs/issues/1293)) - ([d2f2907](https://github.com/ngi-nix/ngipkgs/commit/d2f2907c9d7cc21883b76578920fe1fe6f49ddc2))
- Make Linux build more verbose - ([cdead82](https://github.com/ngi-nix/ngipkgs/commit/cdead8296c0fb5656b6675612c1ed819017552d7))
- Fix dependency url - ([fd71e06](https://github.com/ngi-nix/ngipkgs/commit/fd71e061f1ae7c66be4a45f6988c14571cdd5664))
- Update coreboot hashes - ([9a0260f](https://github.com/ngi-nix/ngipkgs/commit/9a0260f61204b06ced190fcf65c971ba6486b3b0))
- Disable qemu-coreboot-fbwhiptail-tpm1-hotp board - ([8c2e68b](https://github.com/ngi-nix/ngipkgs/commit/8c2e68b431a329eceef3c2ccf9d1443a6be93916))
- Re-enable qemu-coreboot-fbwhiptail-tpm1-hotp board - ([94c1dc9](https://github.com/ngi-nix/ngipkgs/commit/94c1dc93a3d7d5a3ea13c48bfc10f7abde08363a))


### Infra/README.md

- Update instructions on adding keys - ([c094aae](https://github.com/ngi-nix/ngipkgs/commit/c094aae063abccdbe38fd73e081f9503bba67e65))


### Infra/makemake

- Add prince213 to remotebuild - ([55a7746](https://github.com/ngi-nix/ngipkgs/commit/55a7746cc05073e73d8920dc097c977332e1c4b6))


### Infra/makemake/keys

- Add prince213 - ([099df26](https://github.com/ngi-nix/ngipkgs/commit/099df26132400eafc3b9143d9d728d316a40d506))


### Inventaire

- Init - ([3891e97](https://github.com/ngi-nix/ngipkgs/commit/3891e97972f2abae1b78257f3922d696567f8018))


### Inventaire-client

- Init at 4.0.1 - ([71883b6](https://github.com/ngi-nix/ngipkgs/commit/71883b62bb4d2c8745db600586d127289f92a46d))
- Apply patch to offer OpenStreetMap as tile provider - ([078cc55](https://github.com/ngi-nix/ngipkgs/commit/078cc550a33cf001bb05a70d2be8bec0dd28b00a))


### Inventaire-i18n

- Init at 0-unstable-2025-06-12 - ([6b27ece](https://github.com/ngi-nix/ngipkgs/commit/6b27ececb62e3be4cb69819708acbdf902440bfb))
- Fix updateScript command - ([e1fb91d](https://github.com/ngi-nix/ngipkgs/commit/e1fb91d98a652b4f28dd052d119b23c9a5f0c643))


### Inventaire-unwrapped

- Init at 4.0.1 - ([bb7ed94](https://github.com/ngi-nix/ngipkgs/commit/bb7ed94f1be89bad4a41982e0f3187433d480d3f))
- Fix hash - ([232c642](https://github.com/ngi-nix/ngipkgs/commit/232c6420ca7825ef23a3dc7c01c392f55d2b4a08))
- Apply patch to offer OpenStreetMap as tile provider - ([804be7d](https://github.com/ngi-nix/ngipkgs/commit/804be7da42d6f7cd7ac2345cb07f271c11079f2c))


### Liberaforms

- Add explicit format for python deps - ([f1f2038](https://github.com/ngi-nix/ngipkgs/commit/f1f2038139ce82ffec40b3d7ade0b66cdab8d2bb))


### MCaptcha

- Make setup less prone to crashing on startup - ([b1c9132](https://github.com/ngi-nix/ngipkgs/commit/b1c913228a0008ccdb7fdb877dd30ac0b37eda95))
- Wait for postgresql in multiple steps during own services test - ([206aefa](https://github.com/ngi-nix/ngipkgs/commit/206aefa5ac90814015bb27d352dbdfe1d3532c05))


### Makemake

- Limit max-jobs and cores per nix build - ([40378e0](https://github.com/ngi-nix/ngipkgs/commit/40378e0f687c8b1440781180f139ef02d98e0780))
- Set Nix max-silent-time to one hour - ([016b944](https://github.com/ngi-nix/ngipkgs/commit/016b944145454de1a888c26986c0d3a8761387ba))


### Mcaptcha

- Apply patch to fix flaky tests - ([c581774](https://github.com/ngi-nix/ngipkgs/commit/c5817742fa82e1c1c37bee933234fcfcb954fe8b))


### Nominatim

- Add service example and demo - ([fdf719b](https://github.com/ngi-nix/ngipkgs/commit/fdf719b37b9cd0f686d92bc5e70a44156cabf7c4))
- Add demo test - ([f5b1c90](https://github.com/ngi-nix/ngipkgs/commit/f5b1c909c7ad41adec7c7fd9014487346cfee486))
- Add program module - ([b277424](https://github.com/ngi-nix/ngipkgs/commit/b277424d1a77afb5a96477c06939eb64cdd50f8d))


### Overvieew

- Modularize examples - ([62238bb](https://github.com/ngi-nix/ngipkgs/commit/62238bbd77e77afea6383c66afdbf0020c6dc3f7))


### Pkgs/atomic-browser

- Add fetcherVersion to fetchDeps - ([f217b65](https://github.com/ngi-nix/ngipkgs/commit/f217b659d45f0e4ab8212c5a80e823aafb28d0b3))


### Pkgs/blink-qt

- Remove temporary pygy fix patch - ([d2ea92f](https://github.com/ngi-nix/ngipkgs/commit/d2ea92fb6b4d6d7458fb03c206a2340b8108b604))


### Pkgs/by-name/leaf

- Remove - ([a80d08d](https://github.com/ngi-nix/ngipkgs/commit/a80d08d05acf0c026cbe2b8f39f57c1e9a5acf9d))


### Pkgs/by-name/lillydap

- Remove - ([f80688d](https://github.com/ngi-nix/ngipkgs/commit/f80688d911f338a1894e9abb8a63de6f0e7334aa))


### Projects/Aerogramme

- Add metadata, subgrants, summary - ([3f109ae](https://github.com/ngi-nix/ngipkgs/commit/3f109ae2eca3ac9089cd931df6cbcb013fe642cb))


### Projects/Agorakit

- Add summary ([#1424](https://github.com/ngi-nix/ngipkgs/issues/1424)) - ([4c5278d](https://github.com/ngi-nix/ngipkgs/commit/4c5278dced888ea28a3261b3b701d4f5b39bf23d))


### Projects/Alive2

- Add summary ([#1425](https://github.com/ngi-nix/ngipkgs/issues/1425)) - ([c6a6343](https://github.com/ngi-nix/ngipkgs/commit/c6a63431122f87898d1b5a65cc272a704e029165))


### Projects/AtomicData

- Add metadata, summary, subgrants ([#1426](https://github.com/ngi-nix/ngipkgs/issues/1426)) - ([910127c](https://github.com/ngi-nix/ngipkgs/commit/910127c7de8b9cd5647405e3a5306ed33140822e))


### Projects/Corteza

- Init - ([a28f452](https://github.com/ngi-nix/ngipkgs/commit/a28f452d2fd1214061da823a1dd6874478879eca))
- Add demo vm - ([33d9cf7](https://github.com/ngi-nix/ngipkgs/commit/33d9cf7d72f88089ed54e1aa7a689c9b67c233dc))


### Projects/CryptoLyzer

- Refactor files structure - ([97431e1](https://github.com/ngi-nix/ngipkgs/commit/97431e1d33ab4a6b38cbc4a639e64c2c2bd25789))
- Add demo shell - ([a7f9e38](https://github.com/ngi-nix/ngipkgs/commit/a7f9e38234db0217533570ea3318755f7d2504d6))
- Add test VM - ([6176f70](https://github.com/ngi-nix/ngipkgs/commit/6176f70f5b674b3bf2d710bb5af5747cc0bc2451))


### Projects/ERIS

- Init - ([2a1972e](https://github.com/ngi-nix/ngipkgs/commit/2a1972ec59efb5fc90f38cd8d31705d5b39dcfd8))


### Projects/Ethersync

- Migrate to new demo shell format - ([d677d22](https://github.com/ngi-nix/ngipkgs/commit/d677d22f0cc75660c18b8671eb7f19a971fec37b))
- Add neovim with plugins to demo shell - ([1849dc7](https://github.com/ngi-nix/ngipkgs/commit/1849dc7efbfad3b92c9e5355a5e28d3129bddee3))
- Add vscode ethersync extension example - ([ba0317b](https://github.com/ngi-nix/ngipkgs/commit/ba0317ba4d380b2033e5961a2b0a4a436248aca9))


### Projects/Ethersync/default

- Add demo shell usage instructions - ([e631b90](https://github.com/ngi-nix/ngipkgs/commit/e631b90f3dc0b2cc24af4fc725e547d45984d9f4))


### Projects/Gnucap

- Add summary, add additional subgrant ([#1427](https://github.com/ngi-nix/ngipkgs/issues/1427)) - ([3f6cc85](https://github.com/ngi-nix/ngipkgs/commit/3f6cc858b601ae259216bfe8c6c3368e28342632))


### Projects/Kaidan

- Add test vm - ([4d3d8e4](https://github.com/ngi-nix/ngipkgs/commit/4d3d8e424150cd6e633723e525b6cf1efc6226ed))


### Projects/Namecoin

- Add summary, two additional subgrants ([#1429](https://github.com/ngi-nix/ngipkgs/issues/1429)) - ([a497cd4](https://github.com/ngi-nix/ngipkgs/commit/a497cd4ca19444d99878c976064a44beb08ec63c))


### Projects/NodeBB

- Wait until service is ready for demo vm - ([12e3b01](https://github.com/ngi-nix/ngipkgs/commit/12e3b01481cdcc5048d8734d6b3c1d7e49772acb))
- Add option to open ports in firewall - ([1026893](https://github.com/ngi-nix/ngipkgs/commit/10268939de0e64471d4fbf5e8d2bf346945962e9))
- Move instructions to module - ([02e109b](https://github.com/ngi-nix/ngipkgs/commit/02e109b1b2a1e39d86c0ff5544bdac4387fafd6e))


### Projects/Omnom

- Add demo vm - ([7883dba](https://github.com/ngi-nix/ngipkgs/commit/7883dba529cf0f15a0b79e6c4a7598c028247aea))
- Add link to config - ([8225471](https://github.com/ngi-nix/ngipkgs/commit/82254713b888c7d93642ddd60ed9cda2851e5aa6))


### Projects/OpenWebCalendar

- Add summary, additional subgrant ([#1428](https://github.com/ngi-nix/ngipkgs/issues/1428)) - ([8234a1e](https://github.com/ngi-nix/ngipkgs/commit/8234a1e5cc2c6f97192ec81c105840dd0246f98a))


### Projects/PeerTube

- Add demo - ([0b6a1b7](https://github.com/ngi-nix/ngipkgs/commit/0b6a1b7fde30c7eb3bf2674ff4a982ba7ddb8281))


### Projects/Servo

- Add upstream test as demo - ([5dffcc8](https://github.com/ngi-nix/ngipkgs/commit/5dffcc84013ce38713dc0712a5447cb319b89ab9))


### Projects/holo

- Add demo VM  ([#1264](https://github.com/ngi-nix/ngipkgs/issues/1264)) - ([bbdafc5](https://github.com/ngi-nix/ngipkgs/commit/bbdafc50c6b4498ccf2de047becbf2be5d2321b3))


### Projects/jaq

- Add a demo ([#1328](https://github.com/ngi-nix/ngipkgs/issues/1328)) - ([55a9a48](https://github.com/ngi-nix/ngipkgs/commit/55a9a482430253d72336e7890af9cae7ee3c2005))


### Projects/nyxt

- Add demo.shell test - ([d779523](https://github.com/ngi-nix/ngipkgs/commit/d779523a9f6525c4b5b52378597f191145503b81))


### Projects/owasp

- Init - ([0147e5e](https://github.com/ngi-nix/ngipkgs/commit/0147e5efd6b3de25b1cb3986425613be2df3df83))


### Projects/owi

- Init - ([11b0e40](https://github.com/ngi-nix/ngipkgs/commit/11b0e40e1199b9db709a97ad05ec86030dd03201))
- Migrate to upstream test - ([a184282](https://github.com/ngi-nix/ngipkgs/commit/a184282c917e8ea4f155a87b5b3f441013286117))


### Projects/slipshow

- Init - ([2e1eab8](https://github.com/ngi-nix/ngipkgs/commit/2e1eab8c54fdddca644f79103525874e6255a016))
- Add demo-shell functionality - ([332e647](https://github.com/ngi-nix/ngipkgs/commit/332e647b8c28726e8a9e41e08c5d268f12619f48))
- Switch basic test from version to program example - ([ba27386](https://github.com/ngi-nix/ngipkgs/commit/ba27386a98bbbd6eed5a508a439e06ba507e25cf))


### Projects/stalwart

- Init - ([5ea635a](https://github.com/ngi-nix/ngipkgs/commit/5ea635accb71e458679cb7fec8f34041990513ec))


### Python3-msrplib

- Init at 0.21.1 - ([e293521](https://github.com/ngi-nix/ngipkgs/commit/e2935214ac8d0a1af69641ce105b4c45e2f5d892))


### Python3-otr

- Init at 2.1.0 - ([f5725b8](https://github.com/ngi-nix/ngipkgs/commit/f5725b855280ce9a1cb657f70d7699f9515643d7))


### Python3-sipsimple

- Init at 5.3.3.2-mac - ([66b7f63](https://github.com/ngi-nix/ngipkgs/commit/66b7f637e7325dfb5656a3d5c88b57feccaf5a28))


### Python3-xcaplib

- Init at 2.0.1-unstable-2025-03-20 - ([b566af9](https://github.com/ngi-nix/ngipkgs/commit/b566af955c82033455f2172bb0817204d367555a))


### Servo

- Fix subgrant link - ([9076134](https://github.com/ngi-nix/ngipkgs/commit/9076134a1f4e57d643266c77d2932d959c8178fb))


### Shell

- Add ngipkgs-test to test nixpkgs pr's against ngipkgs - ([f4fc801](https://github.com/ngi-nix/ngipkgs/commit/f4fc801ea73ea5338dbe39635de09cf1105c7b55))


### Sylkserver

- Init at 6.5.0 - ([ffcd238](https://github.com/ngi-nix/ngipkgs/commit/ffcd23843427151f6f17e219687ad0ee342edd57))


### Templates

- Add note to open sub-tasks for deliverables ([#1287](https://github.com/ngi-nix/ngipkgs/issues/1287)) - ([3a1b261](https://github.com/ngi-nix/ngipkgs/commit/3a1b2619ebc4dc6cfb2cee6329cd43f1e1ad2e75))


### Treewide

- Nixfmt 1.0.0 changes - ([bfb8eb1](https://github.com/ngi-nix/ngipkgs/commit/bfb8eb1292c6022dfa20711cf820dd2dd7d9ef45))


### Vula

- Fix build - ([6389a94](https://github.com/ngi-nix/ngipkgs/commit/6389a9436efa51971b56f2b0b8786d6d77cac8f9))


### Xrsh

- Remove service definition - ([b63f0ab](https://github.com/ngi-nix/ngipkgs/commit/b63f0ab1e18d549170c90238c1f714be815e4248))


## [25.06](https://github.com/ngi-nix/ngipkgs/compare/25.05..25.06) - 2025-06-30

### .editorconfig

- Add, apply formatting treewide, add to pre-commit hook - ([fa28756](https://github.com/ngi-nix/ngipkgs/commit/fa28756466c2be8db091c35f30564230b175d5e5))


### .github/ISSUE_TEMPLATE

- Fix link to triaging instructions - ([b0e2f65](https://github.com/ngi-nix/ngipkgs/commit/b0e2f65dba3d749a964613916d297c0716b5a9bf))


### CI/CD

- Add test-demo-shell workflow; refactor test script ([#1107](https://github.com/ngi-nix/ngipkgs/issues/1107)) - ([0029e1d](https://github.com/ngi-nix/ngipkgs/commit/0029e1d8eec3a0f80887a7229ae981fa53825c3b))
- Fix archlinux Nix installation for demo test ([#1135](https://github.com/ngi-nix/ngipkgs/issues/1135)) - ([f55acb7](https://github.com/ngi-nix/ngipkgs/commit/f55acb7ba02191cbd1df738e7251c31f41e21555))


### CNSPRCY

- Init with service module and basic test ([#870](https://github.com/ngi-nix/ngipkgs/issues/870)) - ([2073daf](https://github.com/ngi-nix/ngipkgs/commit/2073dafc336f0bebed49e06b1f89eaecab294079))


### CONTRIBUTING.md

- Fix link to triaging instructions - ([fa4d9ce](https://github.com/ngi-nix/ngipkgs/commit/fa4d9ce158ceff062c6b7bba11378e6a79d52fc3))


### Canaille

- Mark test as broken - ([8bc66de](https://github.com/ngi-nix/ngipkgs/commit/8bc66de7dc09220734b1fc42bb2d532c13ecdfae))


### Cryptpad

- Enable upstream test - ([2daf08d](https://github.com/ngi-nix/ngipkgs/commit/2daf08db0812391e3eb299962db8841f496cc76f))
- Actually test the demo - ([707a214](https://github.com/ngi-nix/ngipkgs/commit/707a214a350433f997157adb87e0be48c4f7c9de))
- Move basic test to top-level scope - ([dcf8bfd](https://github.com/ngi-nix/ngipkgs/commit/dcf8bfd6f7d6a8a3f68208f03975a4e994361aef))
- Move module to a separate file - ([884bfcc](https://github.com/ngi-nix/ngipkgs/commit/884bfcc7a41da3d4672c4079564f56e0fa8a7b1a))


### Heads

- Disable qemu-coreboot-fbwhiptail-tpm1-hotp board - ([17f764e](https://github.com/ngi-nix/ngipkgs/commit/17f764e73534e6038eb530daa8b0085a43b9d36d))


### Libervia

- Mark desktop test as broken - ([83c4b7a](https://github.com/ngi-nix/ngipkgs/commit/83c4b7afce2f9e0f3e60e8c95ac589a63c68dcae))


### LibreSOC

- Mark nmigen & verilog derivations as broken - ([345a067](https://github.com/ngi-nix/ngipkgs/commit/345a067a5082b1f1526f2ed219623fe6db3e7c13))


### OpenWebCalendar

- Disable test - ([b1df155](https://github.com/ngi-nix/ngipkgs/commit/b1df155c4ad442dc6e10293b2ae763d00e26a852))


### Overview

- Don't collapse demo instructions - ([a2b4fe6](https://github.com/ngi-nix/ngipkgs/commit/a2b4fe6d3d20b3b84469cdef4c3938584a87e40c))
- Show update script status for derivations  ([#1090](https://github.com/ngi-nix/ngipkgs/issues/1090)) - ([d541d6b](https://github.com/ngi-nix/ngipkgs/commit/d541d6b68266807ee60660691212f58714c089cf))
- Modularize NIX_CONFIG ([#1097](https://github.com/ngi-nix/ngipkgs/issues/1097)) - ([793b174](https://github.com/ngi-nix/ngipkgs/commit/793b1745715f6a6455d40c851fa6bd761f5f0fc6))
- Don't use <section> without title - ([7d64ab6](https://github.com/ngi-nix/ngipkgs/commit/7d64ab6cb074384af3c679afe47da2dc37294016))
- Render demo shell instructions  ([#1082](https://github.com/ngi-nix/ngipkgs/issues/1082)) - ([a097f63](https://github.com/ngi-nix/ngipkgs/commit/a097f63e3ba308b7ea3c763886ec438b923e11b9))
- Move to default.nix and pass it to flake.nix - ([6128b23](https://github.com/ngi-nix/ngipkgs/commit/6128b2374e11aaf584bfd7d2f063a30106fc1d73))
- Refactor nix-config - ([0fa6d13](https://github.com/ngi-nix/ngipkgs/commit/0fa6d13fb779fada15dc1921f0f6d00b51a6fe79))
- Show copy button for all code blocks - ([41a0493](https://github.com/ngi-nix/ngipkgs/commit/41a04936cdd7806916d779ad93c90d9992662e78))
- Show number of projects - ([ff7e36f](https://github.com/ngi-nix/ngipkgs/commit/ff7e36febc9f0d78632f50fc630a8ae399d93f98))
- Show project list letter by letter - ([d7b814d](https://github.com/ngi-nix/ngipkgs/commit/d7b814d0fb3e62d2e1e11fee2f955f0adaaf844b))
- Refactor for demo type - ([86cbd05](https://github.com/ngi-nix/ngipkgs/commit/86cbd0525cc0a8bc294641ff779011b0aabc8f01))
- Use path type for example modules - ([1a7ccdf](https://github.com/ngi-nix/ngipkgs/commit/1a7ccdfab86473a255b16bfc07350b3a32330c68))
- Use evaluated-modules.config.projects - ([4bcbf79](https://github.com/ngi-nix/ngipkgs/commit/4bcbf7906d9f26720aee2ef4b75ad8b016d95a25))
- Introduce darkmode via css mediaquery - ([f0e0675](https://github.com/ngi-nix/ngipkgs/commit/f0e06757c54fadb364cd05a1d1abfa6131859206))


### Pretalx

- Mark test as broken - ([fe9a824](https://github.com/ngi-nix/ngipkgs/commit/fe9a8249622e42ac274c67acb4895eff52c148c0))


### SCION

- Fix wrong test position - ([1ee6e11](https://github.com/ngi-nix/ngipkgs/commit/1ee6e11dfa327e54b8b574669364859c95d81917))


### Anastasis

- 0.6.1-unstable-2025-03-02 -> 0.6.4 - ([563cf15](https://github.com/ngi-nix/ngipkgs/commit/563cf15bfa795dc56f3b0ba7fe21e31a6e905a82))


### Anastasis-gtk

- 0.6.1 -> 0.6.3 - ([9b1c43a](https://github.com/ngi-nix/ngipkgs/commit/9b1c43a62fe94e59ece1e9f56d9dd0f3539cb96a))


### Contibuting

- Issue triaging instructions ([#1095](https://github.com/ngi-nix/ngipkgs/issues/1095)) - ([f156e72](https://github.com/ngi-nix/ngipkgs/commit/f156e7237d9363cfa7b3ae446ced197d0a5da9b6))


### Contributing

- Update running devmode - ([8dc010f](https://github.com/ngi-nix/ngipkgs/commit/8dc010fd7639c2bc11677559c701d3d4681c27df))


### Demo

- Inline nixosSystem - ([4c0b648](https://github.com/ngi-nix/ngipkgs/commit/4c0b648b689dc4c784ffe3c5b03872cc25d137e6))
- Refactor shell apps composition - ([13c4dea](https://github.com/ngi-nix/ngipkgs/commit/13c4dea20faa629d10b430172faad394d018b8ed))
- Add env option to shell - ([22776f7](https://github.com/ngi-nix/ngipkgs/commit/22776f752e2dc780070e983f2c5d0efb352d77b3))


### Demo/vm

- Make getty auto user optional - ([0550976](https://github.com/ngi-nix/ngipkgs/commit/0550976adba8fe48e8bf39d62e4cf143ac3f83ed))


### Draupnir

- Implement project metadata - ([c6d2154](https://github.com/ngi-nix/ngipkgs/commit/c6d2154cfbe639cd34abc6bdb2e3201050d5f020))


### Ethersync

- Init at 0.6.0 - ([bc4e0d3](https://github.com/ngi-nix/ngipkgs/commit/bc4e0d37156cb9871a8f82c92bc8d5992dfb9b09))


### Heads

- Fix build (for now) - ([8a1ec1d](https://github.com/ngi-nix/ngipkgs/commit/8a1ec1da3f80e96ce6de3d024e6bb419087a9bbd))


### Holo

- Add example - ([6c21f6a](https://github.com/ngi-nix/ngipkgs/commit/6c21f6aa8c918145ff033d608809fc5976055cdb))
- Add VM test - ([a402ed9](https://github.com/ngi-nix/ngipkgs/commit/a402ed9135a1ad3498d29a54b147f75b8389f8ee))


### Holo-daemon

- Add service module - ([8e0f43d](https://github.com/ngi-nix/ngipkgs/commit/8e0f43dea1ee5ae8f6e59d4c6722869dcc4287ed))


### Kaidan

- Implement project metadata - ([e1224f1](https://github.com/ngi-nix/ngipkgs/commit/e1224f134af5f0b97ef40d18e77f593b0a5e01c9))
- Implement program - ([71dd36f](https://github.com/ngi-nix/ngipkgs/commit/71dd36f28f696d1fcd65ed00eb31506359e68a70))
- Add example - ([d030374](https://github.com/ngi-nix/ngipkgs/commit/d03037499dfd24c9114414904a3f80c5d73e89fc))


### Kivy-garden-modernmenu

- Init at 0-unstable-2019-12-10 - ([f734ace](https://github.com/ngi-nix/ngipkgs/commit/f734ace9121702b2f7f0ce6a7b2fba4f76c35bbb))


### Lib

- Unify lib' into lib and export lib - ([53a0029](https://github.com/ngi-nix/ngipkgs/commit/53a002933bc67a4cc00387cedbdb38ae564dfe9b))


### Liberaforms

- Replace substituteAll with replaceVars - ([62e9fea](https://github.com/ngi-nix/ngipkgs/commit/62e9fea536db58fe24116d864871efb493b52061))


### MCaptcha

- Fix bring-your-own-services test - ([8ebbad0](https://github.com/ngi-nix/ngipkgs/commit/8ebbad01e1e72e7c7ff755d1624594cf19c1ec49))


### Maintainers/templates/project

- Fix typo - ([0555d7e](https://github.com/ngi-nix/ngipkgs/commit/0555d7e305cffe21a74384bde193c1a6c6e38f43))
- Fix test module option - ([ae06b46](https://github.com/ngi-nix/ngipkgs/commit/ae06b46b432089baa748c3ecd5606daa1583eec8))


### Maintainers/templates/projects

- Fix extra args - ([e0cf8be](https://github.com/ngi-nix/ngipkgs/commit/e0cf8be60cc626359637a9c261367e9bf9a0f512))


### Maintainers/templates/projects/programs

- Add cfg.package as default - ([96154f4](https://github.com/ngi-nix/ngipkgs/commit/96154f436225554038061dd26d007e13a8b3d29a))


### Modules

- Refactor null types - ([e3af1dd](https://github.com/ngi-nix/ngipkgs/commit/e3af1dd8b402417812277c27c3208627b8015c52))


### Nodebb

- Init at 4.4.3 - ([fb0838e](https://github.com/ngi-nix/ngipkgs/commit/fb0838e2edc34662cd444aca27de8a1103b2dce9))
- Fix dart-sass - ([b8cd1b0](https://github.com/ngi-nix/ngipkgs/commit/b8cd1b010baadd7d92b734d0d5f40f407c8f8a7b))


### Nominatim

- Implement project metadata - ([4cedbab](https://github.com/ngi-nix/ngipkgs/commit/4cedbab92230cf5efa86f0d12585a6ff4bb54af8))


### Nvim-ethersync

- Init at 0.6.0 - ([8d663b0](https://github.com/ngi-nix/ngipkgs/commit/8d663b041bbfa273906f72bf63fafc8093c35e73))


### Nyxt

- Give test more memory - ([8017173](https://github.com/ngi-nix/ngipkgs/commit/80171731753e4006f11d8052ce32365ca418f882))


### Peertube-plugin-akismet

- 0.1.1 > 0-unstable-2025-05-30 - ([500972e](https://github.com/ngi-nix/ngipkgs/commit/500972ea7c59f6cc103156b0e4f2e5accac2b9c1))


### Peertube-plugin-auth-ldap

- Add update script - ([56cfb3e](https://github.com/ngi-nix/ngipkgs/commit/56cfb3efc88d6b41b5c2c805a6a510e949da7bde))
- 0.0.12 > 0-unstable-2025-05-30 - ([11f498d](https://github.com/ngi-nix/ngipkgs/commit/11f498d42a604b87ae6c64a34fa5c1263ebe5974))


### Peertube-plugin-auth-openid-connect

- Add update script - ([78e8fea](https://github.com/ngi-nix/ngipkgs/commit/78e8fea6ccebde5d13deedba3c7601a91422bde0))
- 0.1.1 > 0-unstable-2025-05-30 - ([ee20f53](https://github.com/ngi-nix/ngipkgs/commit/ee20f530020ea002909515bc36d54e40378edd2e))


### Peertube-plugin-auth-saml2

- Add update script - ([67d73d3](https://github.com/ngi-nix/ngipkgs/commit/67d73d37cbdf71067983a21741f125db61a35465))


### Peertube-plugin-auto-block-videos

- Add update script - ([e264ca5](https://github.com/ngi-nix/ngipkgs/commit/e264ca52ac31a0e22abe7018a81cb335a9a34900))


### Peertube-plugin-auto-mute

- Add update script - ([c6e516b](https://github.com/ngi-nix/ngipkgs/commit/c6e516b72f2b0837aa7ccd3b4abf4ae91d22e7f7))


### Peertube-plugin-hello-world

- Add update script - ([e80e8f6](https://github.com/ngi-nix/ngipkgs/commit/e80e8f6ca070dcaeecefb3cf313825b6c4a50b60))
- 0.0.22 > 0-unstable-2025-05-30 - ([151da38](https://github.com/ngi-nix/ngipkgs/commit/151da386190d10bfe567f214fd1c1ece37a1eeb7))


### Peertube-plugin-livechat

- 10.1.2 > 13.0.0 - ([0c7b074](https://github.com/ngi-nix/ngipkgs/commit/0c7b074415471d8fd37fd4530bed5bc39cc8de3f))
- 13.0.0 > 14.0.0 - ([e0fccbf](https://github.com/ngi-nix/ngipkgs/commit/e0fccbffae0c9e6d12511b5ec27869edff9d64c9))
- Provide expected converse emojis file - ([1115359](https://github.com/ngi-nix/ngipkgs/commit/1115359d022766da5eb694164141850436074a7b))
- Include lrexlib-oniguruma dependency - ([9008eb2](https://github.com/ngi-nix/ngipkgs/commit/9008eb2f334b937cac190448136a07f9782864e3))


### Peertube-plugin-logo-framasoft

- Add update script - ([3dc80cf](https://github.com/ngi-nix/ngipkgs/commit/3dc80cf50a4ea14d13a6bf316a51ff471595c502))
- 0.0.1 > 0-unstable-2025-05-30 - ([784d5cb](https://github.com/ngi-nix/ngipkgs/commit/784d5cba2c602c06b715f4c0304b2ff16be13c8e))


### Peertube-plugin-matomo

- Add update script - ([de6c19e](https://github.com/ngi-nix/ngipkgs/commit/de6c19ee5f3deb467919aac71fd837ccc2aa5586))


### Peertube-plugin-privacy-remover

- Add upadate script - ([9f9a0ab](https://github.com/ngi-nix/ngipkgs/commit/9f9a0ab4361339d0d3b738ce618eeedc106dde75))
- 0.0.1 > 0-unstable-2025-05-30 - ([f711878](https://github.com/ngi-nix/ngipkgs/commit/f711878a2a41de2a4c08a606ef1618e634196c04))


### Peertube-plugin-transcoding-custom-quality

- Add update script - ([bd5e994](https://github.com/ngi-nix/ngipkgs/commit/bd5e9945098f502267c1489d6ff3636d2b7e5a87))
- 0.1.0 > 0-unstable-2025-05-30 - ([b06338f](https://github.com/ngi-nix/ngipkgs/commit/b06338f607af1f79d14c83e8d7993fa9f5a7f61c))


### Peertube-plugin-transcoding-profile-debug

- Add update script - ([da8390d](https://github.com/ngi-nix/ngipkgs/commit/da8390ded1203d86bba7b5ac89e6a6c3e8fc3995))


### Peertube-plugin-video-annotation

- Add update script - ([6ced769](https://github.com/ngi-nix/ngipkgs/commit/6ced7699fc01f6281a9870dbba523759f11c39b1))
- 0.0.8 > 0-unstable-2025-05-30 - ([288f3fe](https://github.com/ngi-nix/ngipkgs/commit/288f3fe44912cb14c5c4b314f838fa12f2c3a4ac))


### Peertube-theme-background-red

- Add update script - ([d8fcf40](https://github.com/ngi-nix/ngipkgs/commit/d8fcf40c7102e2d993f20e0ba3be776d2f383fd3))


### Peertube-theme-dark

- Add update script - ([4baf5e1](https://github.com/ngi-nix/ngipkgs/commit/4baf5e11a13b0d44d7776b735da47d8ad7624842))
- 2.5.0 > 0-unstable-2025-05-30 - ([ddbeb2d](https://github.com/ngi-nix/ngipkgs/commit/ddbeb2d19591f50a4db1cbb18fe5cc69dda41beb))


### Peertube-theme-framasoft

- Add update script - ([1485f9b](https://github.com/ngi-nix/ngipkgs/commit/1485f9bb523f8ce854354f5576aa34805e637d5d))
- 0.0.1 > 0-unstable-2025-05-30 - ([7e24024](https://github.com/ngi-nix/ngipkgs/commit/7e240245c4c44b7e863073fb349708244e2d27b7))


### Peettube-plugin-akismet

- Add update script - ([d00dd21](https://github.com/ngi-nix/ngipkgs/commit/d00dd2199ef3cc593ab97ed3a11eede7e301fea1))


### Pkgs/libervia-backend

- Disable tests for lxml-html-clean - ([ad840b9](https://github.com/ngi-nix/ngipkgs/commit/ad840b939da68b51155315698e3f63d1eda2cbb3))


### Pkgs/openxc7

- 0.8.2-unstable-2025-03-14 -> 0.8.2-unstable-2025-04-03 - ([3005368](https://github.com/ngi-nix/ngipkgs/commit/30053685c7a6f970d98a622b4338a9914f4b5f8e))
- Mark as broken - ([44ff635](https://github.com/ngi-nix/ngipkgs/commit/44ff635b79cf5f8d7b50e381f749ba8759544aae))


### Projects

- Refactor demos to the demo type - ([3fc4beb](https://github.com/ngi-nix/ngipkgs/commit/3fc4beb52aeb72179056f14c50e3c8ccaf11e5fc))
- Re-enable binary artefacts - ([1894444](https://github.com/ngi-nix/ngipkgs/commit/18944442555314e8b525ccc5064bbe52a5520849))
- Accept additional args - ([a64aa7d](https://github.com/ngi-nix/ngipkgs/commit/a64aa7d609135784365efdf61a1f1803661ac051))


### Projects/Draupnir

- Expose - ([cf9c191](https://github.com/ngi-nix/ngipkgs/commit/cf9c191563bc0b7da60b18fd0b94f230b7de9426))
- Add basic example - ([977f112](https://github.com/ngi-nix/ngipkgs/commit/977f112f7d0cd8fb706d4330b9d68c8d429d393c))
- Add demo vm - ([2c5e48e](https://github.com/ngi-nix/ngipkgs/commit/2c5e48e596efb48ec88b7961f3b401234c6b3325))


### Projects/Ethersync

- Init - ([551ee59](https://github.com/ngi-nix/ngipkgs/commit/551ee594d8c769836b217ebd7db45afc949f0f05))
- Test syncing and neovim plugin - ([485ecfc](https://github.com/ngi-nix/ngipkgs/commit/485ecfc64fa3090fd3eb4a10edbdb05bae4e4547))
- Disable ssh backdoor for tests - ([4c4d014](https://github.com/ngi-nix/ngipkgs/commit/4c4d014efff09409f279f4b4a476149f74e9a76b))
- Support demo-shell - ([599da98](https://github.com/ngi-nix/ngipkgs/commit/599da98fb4913783e8f1ccc167ffd8317319b740))


### Projects/NodeBB

- Init - ([9e4155f](https://github.com/ngi-nix/ngipkgs/commit/9e4155f87b24f7875f3168adf41a5f7315302092))
- Init module and add basic example - ([25aebf7](https://github.com/ngi-nix/ngipkgs/commit/25aebf750f80694dd22465cbe890bcd93a027d7f))
- Add option enableLocalDB - ([80071fe](https://github.com/ngi-nix/ngipkgs/commit/80071fe7f1ab446190f09d74b969a3794623cb55))
- Add demo vm - ([bf075a2](https://github.com/ngi-nix/ngipkgs/commit/bf075a24dd9c26932d6a30d3940d439091472c15))


### Projects/OpenWebCalendar

- Add basic example - ([7c3bc80](https://github.com/ngi-nix/ngipkgs/commit/7c3bc809011660f971571145c94b603f405225e5))
- Add demo vm - ([422bc9d](https://github.com/ngi-nix/ngipkgs/commit/422bc9da86c8c6d701bc01a0ea249269274dd717))


### Projects/PeerTube

- Add peertube-cli ([#1142](https://github.com/ngi-nix/ngipkgs/issues/1142)) - ([1cb9757](https://github.com/ngi-nix/ngipkgs/commit/1cb97577f547c1b55ad609942397a35e43385eed))
- Split off livechat test - ([23c51a1](https://github.com/ngi-nix/ngipkgs/commit/23c51a17b608181655a15eda2ded137378ebe7b1))


### Projects/holo

- Init ([#1153](https://github.com/ngi-nix/ngipkgs/issues/1153)) - ([4810584](https://github.com/ngi-nix/ngipkgs/commit/4810584e62513da39b5cdee18ffb4aef4865a982))


### Projects/jaq

- Init ([#1157](https://github.com/ngi-nix/ngipkgs/issues/1157)) - ([06fd1e5](https://github.com/ngi-nix/ngipkgs/commit/06fd1e5c698d3a0a7fb25a342b4aaf1cec0769de))


### Projects/nyxt

- Init - ([8bfa312](https://github.com/ngi-nix/ngipkgs/commit/8bfa312d65082cfadf6dbb24b7ceec4068c1e175))


### Seppo

- Implement project metadata - ([ba41a63](https://github.com/ngi-nix/ngipkgs/commit/ba41a6300921680925cfd9f825d82d10a86ec9c2))


### Steamworks-pulleyback

- Use cmakeFlags instead of calling CMake manually - ([8d51cdd](https://github.com/ngi-nix/ngipkgs/commit/8d51cdd4abb8d481ec4d8836e2e39885fa17665d))


### Templates

- Add Spike - ([4532f12](https://github.com/ngi-nix/ngipkgs/commit/4532f12b23c20ac3a2c9217ee0d122d8906cf1e9))
- Add derivation update task - ([d18cc83](https://github.com/ngi-nix/ngipkgs/commit/d18cc832997b9fc23895ab45b5f3b91adef0e5f7))
- Add derivation packaging task - ([3606c9f](https://github.com/ngi-nix/ngipkgs/commit/3606c9f4f260968dccd8d4ebebc270f455d1b80d))
- Add example and demo tasks - ([2e5340f](https://github.com/ngi-nix/ngipkgs/commit/2e5340f9b09227c005d65d2f395ec22b9c4ca247))
- Refactors - ([5cd6497](https://github.com/ngi-nix/ngipkgs/commit/5cd649758b03108e170dd0cd7bcd2cb5a1ddb844))
- Refactor derivation updates - ([2da80de](https://github.com/ngi-nix/ngipkgs/commit/2da80de5be90488ec5f50fafe367c80422a71879))


### Treewide

- Use moduleLocFromOptionString to locate re-exported modules - ([152555b](https://github.com/ngi-nix/ngipkgs/commit/152555b85bc5e35252f9464663e73ecfe0964b9f))
- Use pkgs.nixosTests for exported tests - ([b04637e](https://github.com/ngi-nix/ngipkgs/commit/b04637eedf6bc29cc6296961dfbed49f12608919))
- Use module attribute in tests - ([5a13553](https://github.com/ngi-nix/ngipkgs/commit/5a13553ddf9155380fd5fdc3a424edf78edbfe30))
- Mark broken project tests with problem type - ([8109be9](https://github.com/ngi-nix/ngipkgs/commit/8109be98c58242de1c5cc070320beaa672b70a2d))


### Xrsh

- Implement project metadata - ([1ed58af](https://github.com/ngi-nix/ngipkgs/commit/1ed58af05fb0f3f4a6393d8ec116fed19e79385b))
- Implement xrsh program ([#1093](https://github.com/ngi-nix/ngipkgs/issues/1093)) - ([ad53bee](https://github.com/ngi-nix/ngipkgs/commit/ad53bee11af3646d68ca66510a378f050dec89a8))
- Add shell demo ([#1118](https://github.com/ngi-nix/ngipkgs/issues/1118)) - ([08225b3](https://github.com/ngi-nix/ngipkgs/commit/08225b32f15109510d5a91f64f219f218aa6363c))


### Xrsh/demo-shell

- Remove hardcoded env variable - ([34110d0](https://github.com/ngi-nix/ngipkgs/commit/34110d03f0844c04fda65ff4d6a81054396b8ef3))


## [25.05](https://github.com/ngi-nix/ngipkgs/compare/25.04..25.05) - 2025-05-30

### Bug Fixes

- Declare submodule attributes in options - ([c58ebe6](https://github.com/ngi-nix/ngipkgs/commit/c58ebe6dc8ce7a513b2b941df601ca1e78c88567))
- Access types recursively in types.nix - ([43bb1fe](https://github.com/ngi-nix/ngipkgs/commit/43bb1fe1236dda3bcb2f9ed1b32087c88700994b))
- Use deferredModule - ([f0b15b3](https://github.com/ngi-nix/ngipkgs/commit/f0b15b30969420a5d719d2be3a41b3fc6886ffa4))
- Modules for services and programs - ([31ceda4](https://github.com/ngi-nix/ngipkgs/commit/31ceda497e8455875a184c3cd8613cd868dbb757))
- Add name option for programs - ([b953501](https://github.com/ngi-nix/ngipkgs/commit/b9535015ff3196991075a00c45c0a35cd03a27dd))


### CI

- Move NIX_CONFIG into workflow YAML - ([1b51235](https://github.com/ngi-nix/ngipkgs/commit/1b51235c13adecf7933e14fbb0c82dac9f7393e4))


### CI/CD

- *test-demo-vm:* Add ubuntu 25.04 to test matrix - ([1a9c481](https://github.com/ngi-nix/ngipkgs/commit/1a9c48119e1fcc2accf2694ea2129d7e67293c99))
- Add VM test-demo workflow ([#719](https://github.com/ngi-nix/ngipkgs/issues/719)) - ([78a67ca](https://github.com/ngi-nix/ngipkgs/commit/78a67ca3fe83896363ef916af4e41483b5591103))
- Use branch's ngipkgs when testing demo - ([8b6c680](https://github.com/ngi-nix/ngipkgs/commit/8b6c68048e98d3b8b3e571c9c3e9e3d750cd3b43))


### Documentation

- Add usage instructions for overview's devmode - ([1b4f89e](https://github.com/ngi-nix/ngipkgs/commit/1b4f89e381d84e8b56e865fde2d3236eda028c61))


### Overview

- Fix a hard coded prefix for model options - ([7791012](https://github.com/ngi-nix/ngipkgs/commit/7791012006a592222eff0fcfaeafd3cd61c5f57d))
- Move optionsDoc to default.nix - ([96b5b84](https://github.com/ngi-nix/ngipkgs/commit/96b5b8456f367bb0a530d0985e812dfe1cf2b315))
- Add devmode - ([a7a17ef](https://github.com/ngi-nix/ngipkgs/commit/a7a17ef37026456d46223c6cf5a3d91486a2c4cf))
- Don't load copy button when JS is disabled - ([6d0fa81](https://github.com/ngi-nix/ngipkgs/commit/6d0fa81298c7f3039adb7ae3a93db2227e479cda))
- Show tags for projects with a demo - ([71b96aa](https://github.com/ngi-nix/ngipkgs/commit/71b96aaef81db1edc68a523b456e02e958b8b267))
- Compare output between typing system - ([fa44a49](https://github.com/ngi-nix/ngipkgs/commit/fa44a495da2d6fb93085d4bca98fb0de5ae7614a))
- Implement project list item as a module - ([3b1a92d](https://github.com/ngi-nix/ngipkgs/commit/3b1a92d102670ac8b2291efa80da5a7ad8476c7c))
- Implement the whole project list using modules ([#1051](https://github.com/ngi-nix/ngipkgs/issues/1051)) - ([55dbfb2](https://github.com/ngi-nix/ngipkgs/commit/55dbfb268e7effdb8405dbb6cdd9c7dd83db36c2))


### Vula

- Fix option name in example description - ([6f20e96](https://github.com/ngi-nix/ngipkgs/commit/6f20e96b98e6b54792b02700895f23bf22dd3835))
- Mark test as broken - ([bea0080](https://github.com/ngi-nix/ngipkgs/commit/bea008041ce2a2f3e202345ae18ddcc458bae20a))


### Cryptpad

- Fix demo port forwarding - ([ca283ab](https://github.com/ngi-nix/ngipkgs/commit/ca283abc59ec7bbf2ce2a14bb8c01a1de26edde3))


### Demo

- Refactor vm config - ([52c0b88](https://github.com/ngi-nix/ngipkgs/commit/52c0b887994e3f497ef21878ccfc2c7b8b292d5c))
- Init app-shell; separate vm and shell functions - ([429ce97](https://github.com/ngi-nix/ngipkgs/commit/429ce976d018147357e0d8c2691836f7af611f3e))


### Heads

- Fix hash - ([d775320](https://github.com/ngi-nix/ngipkgs/commit/d77532076757eb9614205c1c0296650070ea3cfc))


### Hyperbeam

- Remove derivation - ([b5838be](https://github.com/ngi-nix/ngipkgs/commit/b5838bed7457ce7a7ee04d018a76831d2730b2c6))


### Infra/secrets

- Update Cachix token - ([0bff25d](https://github.com/ngi-nix/ngipkgs/commit/0bff25de052700ec7dd985c7ff18ad30b332b6f7))


### Livervia-backend

- Remove unused deps - ([4e4d1e3](https://github.com/ngi-nix/ngipkgs/commit/4e4d1e3f7b3cacf70712c144bbd288328878df4a))


### Mitmproxy

- Use app-shell - ([2310087](https://github.com/ngi-nix/ngipkgs/commit/2310087c3277d44448faa5677c9843da0b7f75d0))


### Models

- Add subgrant type ([#988](https://github.com/ngi-nix/ngipkgs/issues/988)) - ([351ff77](https://github.com/ngi-nix/ngipkgs/commit/351ff77b600e404a4a4d09a7268c40059b4aa21f))
- Add link. library and binary types ([#989](https://github.com/ngi-nix/ngipkgs/issues/989)) - ([81be0ba](https://github.com/ngi-nix/ngipkgs/commit/81be0bad3321f1bd5b483151531c850f1ae43312))
- Add test and example types  ([#985](https://github.com/ngi-nix/ngipkgs/issues/985)) - ([c4be874](https://github.com/ngi-nix/ngipkgs/commit/c4be874f09c45c39881c57ec4cca9221bdf29aff))
- Add service type  ([#986](https://github.com/ngi-nix/ngipkgs/issues/986)) - ([4af3e5f](https://github.com/ngi-nix/ngipkgs/commit/4af3e5f735e26b68f2b339361cde14274ea37149))
- Add program type ([#987](https://github.com/ngi-nix/ngipkgs/issues/987)) - ([38d023d](https://github.com/ngi-nix/ngipkgs/commit/38d023d9e4996bcd9d388d41dbf165e330a47d1c))
- Init typing with module system - ([34fe704](https://github.com/ngi-nix/ngipkgs/commit/34fe704599b443cb200823fd4ae1514b205e2f3f))


### Modules

- Move projects to types - ([171d582](https://github.com/ngi-nix/ngipkgs/commit/171d582537f2cc70f34cc88d8d6359c294e0451f))
- Cleanup custom types - ([67dc499](https://github.com/ngi-nix/ngipkgs/commit/67dc499b62a1207a60cd2f87b262b913bbf449df))
- Refactor metadata type - ([27755b0](https://github.com/ngi-nix/ngipkgs/commit/27755b0ee55039cec5a23c3f5e3a9b255fa359cf))
- Re-order options - ([7207e9f](https://github.com/ngi-nix/ngipkgs/commit/7207e9f1912aa2937876135035e897ffb6439f1e))
- Distinguish between custom and nixpkgs types - ([5fc2ab3](https://github.com/ngi-nix/ngipkgs/commit/5fc2ab3865ec93829e378fc38ab6c8b9e7e302c2))


### Projects/types

- Fixup ([#994](https://github.com/ngi-nix/ngipkgs/issues/994)) - ([45c158b](https://github.com/ngi-nix/ngipkgs/commit/45c158bf55e982888ccf9061a37e69833e103a37))


### {xeddsa,libxeddsa}

- Remove derivations - ([3ae1ded](https://github.com/ngi-nix/ngipkgs/commit/3ae1deda794735de941451b84c7db2afe2f8a43a))


## [25.04](https://github.com/ngi-nix/ngipkgs/compare/25.03..25.04) - 2025-04-29

### Agorakit

- Projects-old -> projects - ([1206ca2](https://github.com/ngi-nix/ngipkgs/commit/1206ca2062bbd0a3a759093cc3fd53e114786f13))


### Alive2

- Projects-old -> projects - ([94feb72](https://github.com/ngi-nix/ngipkgs/commit/94feb7296d795126c848e936b2100da871d805c4))


### Briar

- Add metadata - ([63c4b95](https://github.com/ngi-nix/ngipkgs/commit/63c4b957cf8709b74f65540e1938643a1bf5ea2a))


### CNSPRCY

- Projects-old -> projects - ([dd97846](https://github.com/ngi-nix/ngipkgs/commit/dd97846b78a896f2854bd6390128165e2871a092))


### CONTRIBUTING

- Add public Matrix room - ([d7c08c6](https://github.com/ngi-nix/ngipkgs/commit/d7c08c63d06d703bb045f8131c7c5415fdd955d6))


### Canaille

- Projects-old -> projects - ([5470a69](https://github.com/ngi-nix/ngipkgs/commit/5470a691a1a6342892713ea331fc0cd49604cf96))


### Cryptpad

- Refactor demo; add openPorts option - ([1d1a545](https://github.com/ngi-nix/ngipkgs/commit/1d1a5452db53757c233a7e79b3b775fe2bf71264))


### DMT-Core

- Projects-old -> projects - ([c09fdcb](https://github.com/ngi-nix/ngipkgs/commit/c09fdcb35b53a0ff58b6857b6057bc3639ea9744))


### Documentation

- Add instructions for exposing a project - ([a60bfec](https://github.com/ngi-nix/ngipkgs/commit/a60bfecaec243afe8af042ef061a0de3594f8025))


### Dokieli

- Projects-old -> projects - ([d859c2a](https://github.com/ngi-nix/ngipkgs/commit/d859c2ab62fa7ac44dbed441d56280076c8304ef))


### Flake

- Don't check examples - ([fade928](https://github.com/ngi-nix/ngipkgs/commit/fade928a22a38920528134ce38e07daf1691e38b))


### Flarum

- Projects-old -> Projects ([#779](https://github.com/ngi-nix/ngipkgs/issues/779)) - ([ee1171f](https://github.com/ngi-nix/ngipkgs/commit/ee1171f2e775b03938be04f2f40a9a76def67634))
- Delete old project entry - ([dba50ea](https://github.com/ngi-nix/ngipkgs/commit/dba50ea3099b48b4233863b8d3187fd8e7043a70))


### Forgejo

- Projects-old -> projects - ([f5ba771](https://github.com/ngi-nix/ngipkgs/commit/f5ba771e7201c47c2700cf575454e08ccee77043))


### GNUTaler

- Projects-old -> projects - ([0ed438e](https://github.com/ngi-nix/ngipkgs/commit/0ed438eaa2f801043b2412e6baac78da7ecf39c6))


### Galene

- Add project ([#716](https://github.com/ngi-nix/ngipkgs/issues/716)) - ([cfc27bb](https://github.com/ngi-nix/ngipkgs/commit/cfc27bbd537f1bb85e1ed14ddb77212cd4681f97))


### Gancio

- Move from projects-old to projects - ([87c5504](https://github.com/ngi-nix/ngipkgs/commit/87c550436ab2cc975ebd8b7a118261695cae5a4c))


### Heads

- Add project metadata & VM test - ([ac7f6f0](https://github.com/ngi-nix/ngipkgs/commit/ac7f6f008c37405c72ca905833fa3f2aaeef342b))
- Provide option to override allowlist of boards, symlink all allowed boards' ROMs - ([469210c](https://github.com/ngi-nix/ngipkgs/commit/469210c717541bc85bae6ff92fc63894bba71286))
- Add more details about where images end up, and how they're named - ([c083189](https://github.com/ngi-nix/ngipkgs/commit/c083189c4fde50d1b5883cefe67164933842c906))


### Hypermachines

- Projects-old -> projects - ([e801f67](https://github.com/ngi-nix/ngipkgs/commit/e801f67f998f772f13fffc74134322c33cb547bb))


### Inko

- Projects-old -> projects - ([d79a736](https://github.com/ngi-nix/ngipkgs/commit/d79a736db091d5d53dd5f23a7b8af002e6f69800))


### KiKit

- Projects-old -> projects - ([ff38ca1](https://github.com/ngi-nix/ngipkgs/commit/ff38ca1c4f48890bc1d60d338ad231e2d68e57b6))


### Liberaforms

- Projects-old -> projects - ([efc6cdb](https://github.com/ngi-nix/ngipkgs/commit/efc6cdb857f6d4fd7cfdbf1a2fe2e08216202d29))
- Extract test config into separate example - ([c85071d](https://github.com/ngi-nix/ngipkgs/commit/c85071dc95203d4fdbddd12726fd4b9570e8eacf))


### LibreSOC

- Projects-old -> projects - ([242a043](https://github.com/ngi-nix/ngipkgs/commit/242a0431bff31eb901fae8fbbff66625bcbdf7af))


### Librecast

- Projects-old -> projects - ([4f55e0b](https://github.com/ngi-nix/ngipkgs/commit/4f55e0b1d0a0ccb9f06466f02717b544e4050b20))


### Meta-Presses

- Projects-old -> projects - ([695368e](https://github.com/ngi-nix/ngipkgs/commit/695368e85fb11eacde9018b2f6bf2b7fe5408546))


### Misskey

- Projects-old -> Projects ([#798](https://github.com/ngi-nix/ngipkgs/issues/798)) - ([9884bb1](https://github.com/ngi-nix/ngipkgs/commit/9884bb18ef79a716535350feedf0704e040a9681))


### Naja

- Projects-old -> projects - ([d43d9c1](https://github.com/ngi-nix/ngipkgs/commit/d43d9c14ebe69e15fd0895648096c774694e7fe7))


### Nitrokey

- Projects-old -> projects - ([091c43f](https://github.com/ngi-nix/ngipkgs/commit/091c43f79e4d62f0ffea0d15bbeb8997df4ea70e))


### Omnom

- Remove form projects-old - ([768faae](https://github.com/ngi-nix/ngipkgs/commit/768faaea27694647d54cdd962f5b44d9de273acd))


### Overview

- Fix wording ([#636](https://github.com/ngi-nix/ngipkgs/issues/636)) - ([390978e](https://github.com/ngi-nix/ngipkgs/commit/390978e48632fd99c0d6b38fc27767f18c01a186))
- Remove packages - ([b0fb7b5](https://github.com/ngi-nix/ngipkgs/commit/b0fb7b5268244d0cdb8f8af026061c57657f3b96))
- Move to `overview` - ([e4893c1](https://github.com/ngi-nix/ngipkgs/commit/e4893c1afa44f09488cd946ee8d72a1bbdfe8778))
- Render service demos ([#668](https://github.com/ngi-nix/ngipkgs/issues/668)) - ([5088191](https://github.com/ngi-nix/ngipkgs/commit/5088191f2b7f53a5521b4f894a2ea9db0a2af6d8))
- Provide download and copy buttons for demo code ([#962](https://github.com/ngi-nix/ngipkgs/issues/962)) - ([75f282f](https://github.com/ngi-nix/ngipkgs/commit/75f282f1affd6874c48eb75e5255ec68ac5118cc))


### PeerTube

- Projects-old -> projects - ([e9b3b0f](https://github.com/ngi-nix/ngipkgs/commit/e9b3b0fda96defc3413c0fe7f838ae1297559e76))


### Pixelfed

- Projects-old -> projects - ([a253db2](https://github.com/ngi-nix/ngipkgs/commit/a253db2dd2169f964e64a1cad83d754c81b77eb5))


### Pretalx

- Projects-old -> projects - ([c9959b8](https://github.com/ngi-nix/ngipkgs/commit/c9959b8181446f0b71f7b3d131d7f0ffa4bd6da4))


### Rosenpass

- Projects-old -> projects ([#786](https://github.com/ngi-nix/ngipkgs/issues/786)) - ([bde2830](https://github.com/ngi-nix/ngipkgs/commit/bde2830058f60a1d5a8dd256e660b590bc941332))


### SCION

- Projects-old -> projects ([#715](https://github.com/ngi-nix/ngipkgs/issues/715)) - ([51793ff](https://github.com/ngi-nix/ngipkgs/commit/51793ff4b032d718e21a5f15620171126f5a26f8))


### Servo

- Projects-old -> projects - ([3350186](https://github.com/ngi-nix/ngipkgs/commit/3350186ec1e7851e3669a09dac917745827e611d))


### Stract

- Projects-old -> projects - ([28e565e](https://github.com/ngi-nix/ngipkgs/commit/28e565e199ec3adc71a6af211e433bfacab40a4e))


### Vula

- Projects-old -> projects - ([b49ab15](https://github.com/ngi-nix/ngipkgs/commit/b49ab15335d028255b645991671fe584cc53c4d6))


### Wireguard

- Projects-old -> projects - ([301378d](https://github.com/ngi-nix/ngipkgs/commit/301378d18a441a7454ef8ff5a39204e0d336b00a))


### Anastasis

- 0.6.1 -> 0.6.1-unstable-2025-03-02 - ([c5ec469](https://github.com/ngi-nix/ngipkgs/commit/c5ec469f8f5140376213dc85f7afc3881444cd4f))


### Arpa2

- Projects-old -> projects - ([1acc99c](https://github.com/ngi-nix/ngipkgs/commit/1acc99c0b146ee2799bfdbf0ba057eec2d8493c5))


### Autobase

- 1.0.0-alpha.9 -> 7.2.2 ([#707](https://github.com/ngi-nix/ngipkgs/issues/707)) - ([bcc8c78](https://github.com/ngi-nix/ngipkgs/commit/bcc8c7815384ffd7fb9925b301ec3f0fbf66f0b9))


### Corestore

- 7.0.23 -> 7.1.0 - ([03bd490](https://github.com/ngi-nix/ngipkgs/commit/03bd4908293bced4e5ff9d983a381e5dca9349d0))


### Gnunet

- Projects-old -> projects ([#750](https://github.com/ngi-nix/ngipkgs/issues/750)) - ([fe2fd0e](https://github.com/ngi-nix/ngipkgs/commit/fe2fd0e1fe05b07ea41be8498ae237d6f1cdfde7))


### Gnunet-messenger-cli

- 0.3.0-unstable-2025-01-07 -> 0.3.1 - ([1974bfa](https://github.com/ngi-nix/ngipkgs/commit/1974bfaaa5e2832482b8a4f7ef6faca2079138d2))


### Heads

- Expose function to override allowList - ([25d2c2a](https://github.com/ngi-nix/ngipkgs/commit/25d2c2a9bd9426583f4dcb3f46f822c6ab4e4608))
- Acknowledge unmaintained & untested boards - ([a50e09f](https://github.com/ngi-nix/ngipkgs/commit/a50e09f5e51e97a4bb7dbd4ccfcf083a39f2994a))


### Heads.*

- Init at 0.2.1-unstable-2025-04-03 - ([ae605a6](https://github.com/ngi-nix/ngipkgs/commit/ae605a651f230994582b0ec64e9668766c98d2b2))


### Holo-cli

- Init at 0.4.0-unstable-2025-04-01 - ([ea5d6e8](https://github.com/ngi-nix/ngipkgs/commit/ea5d6e8f1c406e6378e3cc484d39f2df0d0137bc))


### Holod

- Init at 0.7.0 - ([3af2d5f](https://github.com/ngi-nix/ngipkgs/commit/3af2d5fad2d59c57dc1d4acf4d85ada3890172ff))


### Hyperbeam

- 3.0.1 -> 3.0.2 - ([0b7bbba](https://github.com/ngi-nix/ngipkgs/commit/0b7bbba880590928da217338650447f4babc0d95))


### Hyperblobs

- 2.3.3 -> 2.8.0 - ([6ea9cb4](https://github.com/ngi-nix/ngipkgs/commit/6ea9cb495ba253d30ee3b1fd336c73ff55147d89))


### Hypercore

- 10.28.11 -> 11.1.2 ([#710](https://github.com/ngi-nix/ngipkgs/issues/710)) - ([2d9913f](https://github.com/ngi-nix/ngipkgs/commit/2d9913f5bd89665a592e83589619565ddba3e036))


### Hyperswarm

- 4.7.3 -> 4.11.1 ([#921](https://github.com/ngi-nix/ngipkgs/issues/921)) - ([46c8413](https://github.com/ngi-nix/ngipkgs/commit/46c8413f08e75552fecc2c1a848975e383baa73c))


### Kbin

- Projects-old -> projects - ([a4e1882](https://github.com/ngi-nix/ngipkgs/commit/a4e1882a1bf556cedafd2978be0f08b1ab1f9daa))


### Lib

- Add moduleLocFromOptionString ([#857](https://github.com/ngi-nix/ngipkgs/issues/857)) - ([35b9c8d](https://github.com/ngi-nix/ngipkgs/commit/35b9c8d66bd21d0769817546fdf04f34ebc1c8a6))


### Lib25519

- Projects-old -> projects - ([043a89c](https://github.com/ngi-nix/ngipkgs/commit/043a89caad6abd8d7af968198cd35cfc8553f6de))


### Libervia-backend

- Relax dependencies - ([ddfc8ac](https://github.com/ngi-nix/ngipkgs/commit/ddfc8ac457b64080720355ea414fdc7445cfb0a2))


### Libgnunetchat

- 0.5.0-unstable-2025-01-07 -> 0.5.3 - ([68a338c](https://github.com/ngi-nix/ngipkgs/commit/68a338cea336662afdb7c6c3037a136b7eaa8ce2))


### Libresoc

- Recythonize ([#801](https://github.com/ngi-nix/ngipkgs/issues/801)) - ([9e7f93d](https://github.com/ngi-nix/ngipkgs/commit/9e7f93d1ed565643417c80262d79d634773507ec))


### Libresoc-nmigen

- Use fetchCargoVendor - ([7225a16](https://github.com/ngi-nix/ngipkgs/commit/7225a16018bf41185c77aa13c195c0b63997526e))
- Python39 -> python3 - ([e8ac85b](https://github.com/ngi-nix/ngipkgs/commit/e8ac85b3fb957199e7e72d6e095044aaabceb46a))
- Add build-system; set pyproject - ([1306c42](https://github.com/ngi-nix/ngipkgs/commit/1306c422d53b669ff16e64526db03761568a7cd3))
- Add modgrammar - ([0c7d3b5](https://github.com/ngi-nix/ngipkgs/commit/0c7d3b5828333210d0ab0317667f5cec4333cd84))
- Drop package overrides - ([c767b2c](https://github.com/ngi-nix/ngipkgs/commit/c767b2cb8e9e585397bd8c698938f8d8baa6a3aa))


### MCaptcha

- Projects-old -> Projects ([#817](https://github.com/ngi-nix/ngipkgs/issues/817)) - ([fc70b9f](https://github.com/ngi-nix/ngipkgs/commit/fc70b9f81d0bfd7964fb5b79f27de2b314f0a828))


### Makemake

- Setup CryptPad service on Caddy and host ([#858](https://github.com/ngi-nix/ngipkgs/issues/858)) - ([bbf2cda](https://github.com/ngi-nix/ngipkgs/commit/bbf2cdaa6ba3d6c6f576d188df34cc8c508292ab))


### Metrics

- Move to maintainers - ([9fcf879](https://github.com/ngi-nix/ngipkgs/commit/9fcf87994f78f70ddebf3a84ca051b15444e8b2a))
- Remove `with lib;` - ([c63f0a2](https://github.com/ngi-nix/ngipkgs/commit/c63f0a2debfdff81b59031f9cb86fe2a1e014a6c))


### Mitmproxy

- Projects-old -> projects - ([9a2dc19](https://github.com/ngi-nix/ngipkgs/commit/9a2dc193f600adb2643ea17632b2d6e15b681f41))


### Models

- Add subgrant type - ([1f67439](https://github.com/ngi-nix/ngipkgs/commit/1f67439d20e1da933bb08331f31cfc733332aac2))


### Ntpd-rs

- Projects-old -> projects ([#832](https://github.com/ngi-nix/ngipkgs/issues/832)) - ([10dfb1f](https://github.com/ngi-nix/ngipkgs/commit/10dfb1f2d3c39d5c97d48bbe60e839651317d786))


### Proximity-matcher

- Init at 0-unstable-2023-12-23 - ([7559c5a](https://github.com/ngi-nix/ngipkgs/commit/7559c5a4fd0b34241cf52e7f4a1fc2d5c3935789))
- Add project - ([3c03a5e](https://github.com/ngi-nix/ngipkgs/commit/3c03a5e3dca477642506bc8aa4f9260029f3cfe0))


### Taldir

- 1.0.3 -> 1.0.5 - ([02ce465](https://github.com/ngi-nix/ngipkgs/commit/02ce465c911a3c61791a6f15be2f6001c33317d9))


### Tslib

- Projects-old -> projects - ([b6d6247](https://github.com/ngi-nix/ngipkgs/commit/b6d62473f51f5d51282554eed8a6daee2c22a700))


### Twister

- Fix build - ([31af26e](https://github.com/ngi-nix/ngipkgs/commit/31af26e531d0f5c7f5a4fb3358e02709fa354aaf))


### Wireguard-rs

- Update cargo lock - ([7cc5acb](https://github.com/ngi-nix/ngipkgs/commit/7cc5acb83de0ef7b27ea5d460a06d825a9618dd6))


## [25.03](https://github.com/ngi-nix/ngipkgs/compare/25.02..25.03) - 2025-03-28

### Aerogramme

- Migrate to new project structure - ([519b6c5](https://github.com/ngi-nix/ngipkgs/commit/519b6c57d36a6f6907c16d9a9ce62c4bde07ebfd))
- Fix module option ([#566](https://github.com/ngi-nix/ngipkgs/issues/566)) - ([ff95b2c](https://github.com/ngi-nix/ngipkgs/commit/ff95b2c147a7f337ef2083831c493bb853974790))


### AtomicData

- Migrate to new project structure - ([d9e8a4a](https://github.com/ngi-nix/ngipkgs/commit/d9e8a4afc62e23c64317ecc9cd22b7715ab05693))
- Fix test - ([0d6a470](https://github.com/ngi-nix/ngipkgs/commit/0d6a4708478e42da0b04e6a608ea138b62a418b6))


### Bug Fixes

- Change example module type to path - ([68126ee](https://github.com/ngi-nix/ngipkgs/commit/68126ee5a1a987383df89ce68cba029002c2fc05))
- Top-level examples and tests not being mapped - ([8a783ca](https://github.com/ngi-nix/ngipkgs/commit/8a783ca427ac2c0e0a87b74c7e291276857d538d))


### CI/CD

- Add templates to check - ([6d537c6](https://github.com/ngi-nix/ngipkgs/commit/6d537c6b7b2e9e541a043db52f2ec82aaf836ee8))


### CryptoLyzer

- Fix test - ([260b5da](https://github.com/ngi-nix/ngipkgs/commit/260b5dacb92ede309df7e796259fb0f2fcb78081))


### Cryptpad

- Move to projects - ([e036f94](https://github.com/ngi-nix/ngipkgs/commit/e036f94c5849bfaa331999fc3188376bff14a678))
- Add example and test ([#661](https://github.com/ngi-nix/ngipkgs/issues/661)) - ([9b4ae90](https://github.com/ngi-nix/ngipkgs/commit/9b4ae90d8cb79bb53f9770b9cdb2020d4d006ffa))


### Forgejo

- Use nixos tests - ([716f0f5](https://github.com/ngi-nix/ngipkgs/commit/716f0f56604f76aa731b4dd47386028a91a7a0c5))


### Libervia-backend

- Extract from old Libervia, add to new project structure ([#559](https://github.com/ngi-nix/ngipkgs/issues/559)) - ([1408465](https://github.com/ngi-nix/ngipkgs/commit/1408465eb540cf0c6af8db93124558cf318b0f5a))


### MarginaliaSearch

- Wait for X before launching FF in test - ([7a20944](https://github.com/ngi-nix/ngipkgs/commit/7a20944c4f48b5a9608d0abe385a2900b7ba2c5c))
- Projects-old/ -> projects/ - ([0397afc](https://github.com/ngi-nix/ngipkgs/commit/0397afcf07ea7a7ec66363a56ae1a46edd9de941))


### Mastodon

- Introduce module and test from Nixpkgs - ([4f15d4e](https://github.com/ngi-nix/ngipkgs/commit/4f15d4ea549a7103601ea692499a251e4b299a76))


### Omnom

- Move from projects-old/ to projects/ - ([86671ba](https://github.com/ngi-nix/ngipkgs/commit/86671baf55945af9dbd34e867d24b3ac622254b6))


### OpenWebCalendar

- Move from projects-old into projects - ([6801e81](https://github.com/ngi-nix/ngipkgs/commit/6801e819c1033ebbc39e2a404cb7f293d1e5c377))


### Openfire

- Move projects-old/ -> projects - ([f34b4a0](https://github.com/ngi-nix/ngipkgs/commit/f34b4a00425903a4e32cd7130a0c170fad67fd41))


### Overview

- Stable project urls ([#570](https://github.com/ngi-nix/ngipkgs/issues/570)) - ([bdde565](https://github.com/ngi-nix/ngipkgs/commit/bdde5650701edbd5ed5e66ca7b4a867731b52b68))
- Render subgrant names if they exist in the new project model ([#581](https://github.com/ngi-nix/ngipkgs/issues/581)) - ([ed15bd0](https://github.com/ngi-nix/ngipkgs/commit/ed15bd021f36f9396e4d60664599de187f267b2f))
- Mark as experimental, add more information ([#603](https://github.com/ngi-nix/ngipkgs/issues/603)) - ([8330cb3](https://github.com/ngi-nix/ngipkgs/commit/8330cb3fbe10a2ab7001c04e8d7b4e11bf7e7b0e))
- Render project summary, basic styling ([#627](https://github.com/ngi-nix/ngipkgs/issues/627)) - ([713e6bc](https://github.com/ngi-nix/ngipkgs/commit/713e6bcb617d1b742dd5887c1e327a2149f623d3))
- Don't escape option descriptions ([#632](https://github.com/ngi-nix/ngipkgs/issues/632)) - ([7efacc2](https://github.com/ngi-nix/ngipkgs/commit/7efacc2479e16fc0e8e372e0adbd3ad9fb80ed15))
- Better rendering for subgrants ([#633](https://github.com/ngi-nix/ngipkgs/issues/633)) - ([e67bfdd](https://github.com/ngi-nix/ngipkgs/commit/e67bfdddc913a18dcde12e8212e78a44e56666e9))
- Use IBM Plex Mono for monospace applications instead of letting the browser choose - ([21d54f6](https://github.com/ngi-nix/ngipkgs/commit/21d54f6a31b483576db63fc763d32421c2ae3ab1))
- Redesign options rendering with focus on cognitive hierarchy - ([a0e717b](https://github.com/ngi-nix/ngipkgs/commit/a0e717b38819dd90d5a11011608198daee666276))
- Only ever generate html, remove pandoc as dependency ([#673](https://github.com/ngi-nix/ngipkgs/issues/673)) - ([a031bcc](https://github.com/ngi-nix/ngipkgs/commit/a031bcc94e384bd328c90cd44fe34cd3a2f1d66e))
- Don't render default fields when there is no default - ([0cdf06b](https://github.com/ngi-nix/ngipkgs/commit/0cdf06b7db459bd9aee2a4156633382bf0cbac3a))
- Rebuild the rendering flow so that we can use markdown strings ([#684](https://github.com/ngi-nix/ngipkgs/issues/684)) - ([0676f3b](https://github.com/ngi-nix/ngipkgs/commit/0676f3b6ca1720586aa2cc0d5fc53fb59061a0f8))
- Render project snippets with deliverable type and summary text ([#685](https://github.com/ngi-nix/ngipkgs/issues/685)) - ([74803de](https://github.com/ngi-nix/ngipkgs/commit/74803de43af784e771bddfa6b22910dcd3a0efe2))
- Signify readonly options - ([ba81836](https://github.com/ngi-nix/ngipkgs/commit/ba81836f84eb1ce64c102663a45f0857b352cdd8))
- Provide Open Graph information for link previews - ([d2baf73](https://github.com/ngi-nix/ngipkgs/commit/d2baf73990303d254ed9cf7b8796e403390fb22a))
- Fix font URLs - ([ac6c128](https://github.com/ngi-nix/ngipkgs/commit/ac6c12892577bf3518138742ed7ffc3b0c9ddda9))


### Re-Isearch

- Add a VM test ([#586](https://github.com/ngi-nix/ngipkgs/issues/586)) - ([cb687f0](https://github.com/ngi-nix/ngipkgs/commit/cb687f071683e332e47fbd38dfcf389167525b72))


### Atomic-server

- Use finalAttrs - ([1c46150](https://github.com/ngi-nix/ngipkgs/commit/1c46150c6635eed999c472f278d0efaf28e33b1f))


### Atomic-{browser,cli,server}

- 0.39.0 -> 0.40.0 - ([ed81c89](https://github.com/ngi-nix/ngipkgs/commit/ed81c8978714e99feba78031eebbaf820d6cd62b))


### Libervia-backend

- Relax pyopenssl - ([cb708c8](https://github.com/ngi-nix/ngipkgs/commit/cb708c864ea5402d7d585d14619454170fd2f8c0))


### Libresoc-nmigen

- Override tomli - ([a9000f5](https://github.com/ngi-nix/ngipkgs/commit/a9000f53fa67d44cdbda257239ff3068787b220d))


### Makemake

- Enable prometheus node exporter - ([8cccc6d](https://github.com/ngi-nix/ngipkgs/commit/8cccc6da22d5032073434280255628ebe7bb7f15))
- Make contributors admins on buildbot - ([97bbe4e](https://github.com/ngi-nix/ngipkgs/commit/97bbe4e8d259ae09773e9439fe5afce8b84a336f))


### Marginalia-search

- Build slop from source during the build - ([d311d54](https://github.com/ngi-nix/ngipkgs/commit/d311d54a92a5a4259c87229983490be8406aae59))


### Meta-press

- 1.8.17.1 -> 1.8.17.4 - ([e5127bd](https://github.com/ngi-nix/ngipkgs/commit/e5127bd75728bdb6100114763fe2dcd39cbb15b7))


### Models

- Add binary type, make nixos modules optional - ([f6344b2](https://github.com/ngi-nix/ngipkgs/commit/f6344b2620357c584deb86a4936b599c425e4d29))
- Add top-level links - ([88ee146](https://github.com/ngi-nix/ngipkgs/commit/88ee146ce5637e535a2f2aaf24a09f9ff67da5bb))


### OpenXC7

- Import upstream packages, add project ([#616](https://github.com/ngi-nix/ngipkgs/issues/616)) - ([6f14d04](https://github.com/ngi-nix/ngipkgs/commit/6f14d0470067ef18cede6c0813ded1a3d0390c1f))


### Openfire

- 4.9.0 -> 4.9.2 - ([e0da424](https://github.com/ngi-nix/ngipkgs/commit/e0da4246dd668eeb41fc7cc88b0c8a1d004ee065))


### Taldir

- 0-unstable-2024-02-18 -> 1.0.3 - ([e07ff3f](https://github.com/ngi-nix/ngipkgs/commit/e07ff3f80caa5dd136d5dcb2ed6188efe5d2d1d3))


## [25.02](https://github.com/ngi-nix/ngipkgs/compare/25.01..25.02) - 2025-02-25

### Marginalia

- Remove "packages" - ([4b57efc](https://github.com/ngi-nix/ngipkgs/commit/4b57efc41677f149bb4e8619cb8d7547c6a69292))
- Expand description on basic example - ([9680017](https://github.com/ngi-nix/ngipkgs/commit/9680017b001b8d4a0d542f8cd756bef22268f79f))


### Flake

- Change passthru tests so they're unique - ([22ed8f3](https://github.com/ngi-nix/ngipkgs/commit/22ed8f3dbc977e763f86ce6e172cab0034643de6))


### Makemake

- Add summer.nixos.org site and redirects ([#476](https://github.com/ngi-nix/ngipkgs/issues/476)) - ([22541f0](https://github.com/ngi-nix/ngipkgs/commit/22541f0b0b4375ac55590981b0c529620cea8a4f))


### Marginalia-search

- 24.10.0-unstable-2025-02-15 - ([165f24f](https://github.com/ngi-nix/ngipkgs/commit/165f24fdf2aecfd1389cacc0fbaae6fd058b557a))


<!-- generated by git-cliff -->
