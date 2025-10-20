# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Documentation

- Add header to project reference; refactor & generate
- Refactor project template; add demo


### Features

- Init changelog for 2025


### Overview

- Format render-template.py
- Add `unique_id` function to jinja render
- Update demo instructions
- Move some colors to CSS variables
- Use tabs when shell-instructions is a list
- Add source code declaration link to options
- Link missing artefacts to their docs sections
- Fix declaration path with flakes
- Add example files declaration links
- Reuse common functions in modules
- Add project declaration


### Refactor

- Flatten project types; move project up


### Anastasis

- Add update script


### Anastasis-gtk

- Add update script


### Bigbluebutton.bbb-freeswitch-core.libwebsockets

- Copy CMake 4 fix from Nixpkgs


### Blink-qt

- Use derivation from Nixpkgs


### Heads.*

- Fix CMake 4 compatibility
- Cut down amount of CI-built qemu boards


### Helium

- 5.1.0 -> 5.1.1
- Refactor


### Highctidh

- Use derivation from Nixpkgs


### Inventaire-i18n

- 0-unstable-2025-06-12 -> 0-unstable-2025-10-07


### Kbin-backend

- 0.0.1 -> 0.0.1-unstable-2024-02-05; add update script
- Refactor derivation


### Kbin-frontend

- 0.0.1 -> 0.0.1-unstable-2024-02-05


### Makemake

- Migrate from deprecated `authType`


### Meta-press

- Use fetchFromGitLab
- 1.8.17.4 -> 1.9.1


### Nodebb

- Add update script
- 4.4.3 -> 4.6.0


### Openfire

- 4.9.2 -> 5.0.2


### Openxc7

- Add update script; fix build


### Pagedjs-cli

- 0.4.3-unstable-2024-05-31 -> 0-unstable-2024-05-31


### Pkgs/ratman

- Use buildNpmPackage for dashboard


### Pkgs/{libgnunetchat,gnunet-messenger-cli}

- Remove


### Projects/Blink

- Migrate usage instructions


### Projects/Ethersync

- Migrate usage instructions


### Projects/Galene

- Mark stream test as broken
- Migrate usage instructions


### Projects/Irdest

- Refactor and fix test
- Work around ratmand config failure


### Projects/Kaidan

- Migrate usage instructions


### Projects/Kazarma

- Mark test and derivation as broken


### Projects/Nominatim

- Migrate usage instructions


### Projects/PagedJS

- Migrate usage instructions


### Projects/PeerTube

- Migrate usage instructions


### Projects/ReOxide

- Add program module
- Add service module
- Init program and service modules
- Add VM test
- Add service and program examples


### Projects/ntpd-rs

- Migrate usage instructions


### Projects/oku

- Migrate usage instructions


### Projects/owasp

- Migrate usage instructions


### Projects/xrsh

- Migrate usage instructions


### Ratman

- 0.7.0 -> 0.7.0-unstable-2025-09-09; add update script


### Steamworks-pulleyback

- 0.3.0 -> 0.3.0-unstable-2021-08-16


### Taldir

- Add update script


### Types

- Make usage-instructions nullOr


### Verso

- 0-unstable-2025-06-15 -> 0-unstable-2025-06-17


## 25.09 - 2025-09-24

### CI/CD

- Remove ubuntu 24.10
- Use cachix/install-nix-action
- Enable flakes and nix-command in makemake workflow
- Improve security


### Documentation

- Document project types


### Features

- Add mandatory metadata links


### Libervia

- Re-enable & fix tests
- Add VM demo


### Overview

- Only run deployment on ngi-nix/ngipkgs


### Refactor

- Move custom lib to a separate file
- Project composition; reorder attributes


### Bigbluebutton

- Turn into package scope, split packages into individual files
- Put mkSbtDerivation into callPackage scope
- Make more things shared across packages


### Bigbluebutton.bbb-apps-akka

- Use lndir for symlinking deps


### Bigbluebutton.bbb-config

- Init at 3.0.10-bigbluebutton


### Bigbluebutton.bbb-etherpad

- Init at 3.0.10-bigbluebutton


### Bigbluebutton.bbb-freeswitch-core

- Init at 3.0.10-bigbluebutton


### Bigbluebutton.bbb-freeswitch-sounds

- Init at 3.0.10-bigbluebutton


### Bigbluebutton.bbb-fsesl-akka

- Init at 3.0.10-bigbluebutton


### Bigbluebutton.bbb-fsesl-client

- Init at 3.0.10-bigbluebutton


### Flake

- Use the refactoring branch of buildbot-nix
- Follow main again on buildbot-nix


### Infra

- Remove terraform files for abandoned infra


### Libervia-backend

- Unbreak


### Libervia-desktop-kivy

- Unbreak


### Libervia-media

- Unbreak


### Pkgs/kip

- Fix build


### Pkgs/ratman

- Init at 0-unstable-2025-08-24
- 0-unstable-2025-08-24 -> 0-unstable-2025-09-14
- Refactor


### Pkgs/steamworks

- Remove


### Pkgs/steamworks-pulleyback

- Add openssl; refactor


### Pkgs/tlspool

- Fix and modernize


### Pkgs/verso

- Unpin llvmPackages


### Projects

- Batch add mandatory links; refactor subgrants


### Projects/ERIS

- Mark as broken


### Projects/Irdest

- Improve metadata
- Init ratmand module
- Add missing deliverables info
- Init demo
- Properly wait for API in tests
- Adjust service restart times


### Projects/Servo

- Mark test as broken


### Projects/ThresholdOPRF

- Init (#1621)


### Projects/owasp

- Mark test as broken


### Projects/slipshow

- Migrate to upstream test


### Projects/xrsh

- Fix eval warning


### Reoxide

- Init at 0.7.0


### Reoxide-plugin-simple

- Init 0-unstable-2025-09-12


### Wax-server

- Init at 0-unstable-2025-08-14


### Workflows/makemake

- Only run on ngi-nix/ngipkgs


### Workflows/update

- Only run on ngi-nix/ngipkgs


## 25.08 - 2025-08-29

### Bug Fixes

- Demo tests not being exposed


### CI/CD

- Target debian 13 instead of 12


### Cryptpad

- Add example


### Ethersync

- Use vimPlugins.ethersync; enable vscode
- Add example; update test and usage
- Mark test as broken


### Inventaire

- Unbreak test


### Kaidan

- Mark test as broken
- Fix deprecated option; refactor user setup
- Separate demo utils from config


### Libervia

- Mark test as broken


### Overview

- Link deliverable label to option anchor
- Auto open target element on page load
- Add style for option list and alert
- Add navigation breadcrumbs
- Extend pkgs with ngipkgs overlay
- Link to docs for adding demos
- Render non-list subgrants
- Add overview-instructions


### Project/pagedjs

- Implement program and example (#1498)


### Demo

- Modify greet message


### Demo-vm

- Handle graphics better


### Heads

- Rework board enablement, add more boards
- Add more boards that build, add more support for further boards
- Add Librem targets
- Assert that specified board actually exists


### Makemake

- Show full traces on failed builds


### Pagedjs-cli

- Init at 0.4.3-unstable-2024-05-31


### Pkgs/kazarma

- Init at 1.0.0-alpha.1-unstable-2025-06-30


### Programs/holo

- Remove package expression


### Project/Kaidan

- Abstract graphics config


### Projects/Aerogramme

- Clean up project
- Add service module example


### Projects/Kaidan

- Add demo vm
- Disable demo module by default


### Projects/Kazarma

- Init


### Projects/Nitrokey

- Add commons subgrants; refactor


### Projects/Omnom

- Expose tests


### Projects/PagedJS

- Implement demo example
- Implement VM test


### Projects/PeerTube

- Adjust web UI when plugins are managed with Nix
- Add peertube-runner service


### Projects/ReOxide

- Implement metadata


### Projects/Wax

- Implement metadata


### Projects/mitmproxy

- Expose tests
- Add mitmproxy2swagger
- Fix typo


### Projects/ntpd-rs

- Add examples and tests


### Projects/oku

- Init


### Projects/owasp

- Add depscan test
- Switch to upstream tests


### Projects/owi

- Add demo-shell to module.nix


### Projects/verso

- Init


### Treewide

- Split demo configs to a separate module


### Verso

- Init at 0-unstable-2025-06-15


### Wax-client

- Init at 0-unstable-2025-08-14


## 25.07 - 2025-07-31

### .editorconfig

- Ignore .url files


### .git-blame-ignore-revs

- Add nixfmt 1.0.0 reformat commit


### .github/ISSUE_TEMPLATE

- Add demo usage instruction template


### Blink

- Add metadata, module, example and VM test
- Add demo shell


### Documentation

- Add contributor guide on adding examples (#1244)
- Add workflow for implmeneting a program
- Update examples


### Flake

- Add sbt-derivation input


### Galene

- Extend NixOS module
- Add demo; use NixOS tests
- Add description to demo


### Holo

- Fix holo-cli
- Add more potential tests for protocols


### Inventaire

- Init
- Open firewall; print ready message in demo
- Set map tile provider in example/demo to OpenStreetMap


### Overview

- Add button to link examples' docs (#1280)
- Add code-snippet and demo content-types
- Modularize demo instruction
- Render links to contributing tests and instructions
- Add content-type for option (#1288)
- Indicate problems on deliverable tags
- Fix update script status for scopes
- Render missing programs/services
- Fix demo description access
- Refactor option composition
- Use example attribute name as title
- Use top margin in example button
- Fix download button
- Refactor demoFile
- Show demo instructions using markdown


### Refactor

- Project evaluation checking


### Taler

- Remove program; cleanup


### Bigbluebutton.{bbb-common-message,bbb-apps-akka}

- Init at 3.0.10-bigbluebutton


### Blink-qt

- Init at 6.0.4


### Contributing

- Recommend using upstream module examples


### Demo

- Add demo option
- Add more disk space for VM demo


### Devmode

- Enable verbose output


### Ethersync

- Add nix-update-script
- Add versionCheckHook
- Remove in favor of nixpkgs ethersync


### Heads

- Improve updateDepsScript (#1293)
- Make Linux build more verbose
- Fix dependency url
- Update coreboot hashes
- Disable qemu-coreboot-fbwhiptail-tpm1-hotp board
- Re-enable qemu-coreboot-fbwhiptail-tpm1-hotp board


### Infra/README.md

- Update instructions on adding keys


### Infra/makemake

- Add prince213 to remotebuild


### Infra/makemake/keys

- Add prince213


### Inventaire

- Init


### Inventaire-client

- Init at 4.0.1
- Apply patch to offer OpenStreetMap as tile provider


### Inventaire-i18n

- Init at 0-unstable-2025-06-12
- Fix updateScript command


### Inventaire-unwrapped

- Init at 4.0.1
- Fix hash
- Apply patch to offer OpenStreetMap as tile provider


### Liberaforms

- Add explicit format for python deps


### MCaptcha

- Make setup less prone to crashing on startup
- Wait for postgresql in multiple steps during own services test


### Makemake

- Limit max-jobs and cores per nix build
- Set Nix max-silent-time to one hour


### Mcaptcha

- Apply patch to fix flaky tests


### Nominatim

- Add service example and demo
- Add demo test
- Add program module


### Overvieew

- Modularize examples


### Pkgs/atomic-browser

- Add fetcherVersion to fetchDeps


### Pkgs/blink-qt

- Remove temporary pygy fix patch


### Pkgs/by-name/leaf

- Remove


### Pkgs/by-name/lillydap

- Remove


### Projects/Aerogramme

- Add metadata, subgrants, summary


### Projects/Agorakit

- Add summary (#1424)


### Projects/Alive2

- Add summary (#1425)


### Projects/AtomicData

- Add metadata, summary, subgrants (#1426)


### Projects/Corteza

- Init
- Add demo vm


### Projects/CryptoLyzer

- Refactor files structure
- Add demo shell
- Add test VM


### Projects/ERIS

- Init


### Projects/Ethersync

- Migrate to new demo shell format
- Add neovim with plugins to demo shell
- Add vscode ethersync extension example


### Projects/Ethersync/default

- Add demo shell usage instructions


### Projects/Gnucap

- Add summary, add additional subgrant (#1427)


### Projects/Kaidan

- Add test vm


### Projects/Namecoin

- Add summary, two additional subgrants (#1429)


### Projects/NodeBB

- Wait until service is ready for demo vm
- Add option to open ports in firewall
- Move instructions to module


### Projects/Omnom

- Add demo vm
- Add link to config


### Projects/OpenWebCalendar

- Add summary, additional subgrant (#1428)


### Projects/PeerTube

- Add demo


### Projects/Servo

- Add upstream test as demo


### Projects/holo

- Add demo VM  (#1264)


### Projects/jaq

- Add a demo (#1328)


### Projects/nyxt

- Add demo.shell test


### Projects/owasp

- Init


### Projects/owi

- Init
- Migrate to upstream test


### Projects/slipshow

- Init
- Add demo-shell functionality
- Switch basic test from version to program example


### Projects/stalwart

- Init


### Python3-msrplib

- Init at 0.21.1


### Python3-otr

- Init at 2.1.0


### Python3-sipsimple

- Init at 5.3.3.2-mac


### Python3-xcaplib

- Init at 2.0.1-unstable-2025-03-20


### Servo

- Fix subgrant link


### Shell

- Add ngipkgs-test to test nixpkgs pr's against ngipkgs


### Sylkserver

- Init at 6.5.0


### Templates

- Add note to open sub-tasks for deliverables (#1287)


### Treewide

- Nixfmt 1.0.0 changes


### Vula

- Fix build


### Xrsh

- Remove service definition


## 25.06 - 2025-06-30

### .editorconfig

- Add, apply formatting treewide, add to pre-commit hook


### .github/ISSUE_TEMPLATE

- Fix link to triaging instructions


### CI/CD

- Add test-demo-shell workflow; refactor test script (#1107)
- Fix archlinux Nix installation for demo test (#1135)


### CNSPRCY

- Init with service module and basic test (#870)


### CONTRIBUTING.md

- Fix link to triaging instructions


### Canaille

- Mark test as broken


### Cryptpad

- Enable upstream test
- Actually test the demo
- Move basic test to top-level scope
- Move module to a separate file


### Heads

- Disable qemu-coreboot-fbwhiptail-tpm1-hotp board


### Libervia

- Mark desktop test as broken


### LibreSOC

- Mark nmigen & verilog derivations as broken


### OpenWebCalendar

- Disable test


### Overview

- Don't collapse demo instructions
- Show update script status for derivations  (#1090)
- Modularize NIX_CONFIG (#1097)
- Don't use <section> without title
- Render demo shell instructions  (#1082)
- Move to default.nix and pass it to flake.nix
- Refactor nix-config
- Show copy button for all code blocks
- Show number of projects
- Show project list letter by letter
- Refactor for demo type
- Use path type for example modules
- Use evaluated-modules.config.projects
- Introduce darkmode via css mediaquery


### Pretalx

- Mark test as broken


### SCION

- Fix wrong test position


### Anastasis

- 0.6.1-unstable-2025-03-02 -> 0.6.4


### Anastasis-gtk

- 0.6.1 -> 0.6.3


### Contibuting

- Issue triaging instructions (#1095)


### Contributing

- Update running devmode


### Demo

- Inline nixosSystem
- Refactor shell apps composition
- Add env option to shell


### Demo/vm

- Make getty auto user optional


### Draupnir

- Implement project metadata


### Ethersync

- Init at 0.6.0


### Heads

- Fix build (for now)


### Holo

- Add example
- Add VM test


### Holo-daemon

- Add service module


### Kaidan

- Implement project metadata
- Implement program
- Add example


### Kivy-garden-modernmenu

- Init at 0-unstable-2019-12-10


### Lib

- Unify lib' into lib and export lib


### Liberaforms

- Replace substituteAll with replaceVars


### MCaptcha

- Fix bring-your-own-services test


### Maintainers/templates/project

- Fix typo
- Fix test module option


### Maintainers/templates/projects

- Fix extra args


### Maintainers/templates/projects/programs

- Add cfg.package as default


### Modules

- Refactor null types


### Nodebb

- Init at 4.4.3
- Fix dart-sass


### Nominatim

- Implement project metadata


### Nvim-ethersync

- Init at 0.6.0


### Nyxt

- Give test more memory


### Peertube-plugin-akismet

- 0.1.1 > 0-unstable-2025-05-30


### Peertube-plugin-auth-ldap

- Add update script
- 0.0.12 > 0-unstable-2025-05-30


### Peertube-plugin-auth-openid-connect

- Add update script
- 0.1.1 > 0-unstable-2025-05-30


### Peertube-plugin-auth-saml2

- Add update script


### Peertube-plugin-auto-block-videos

- Add update script


### Peertube-plugin-auto-mute

- Add update script


### Peertube-plugin-hello-world

- Add update script
- 0.0.22 > 0-unstable-2025-05-30


### Peertube-plugin-livechat

- 10.1.2 > 13.0.0
- 13.0.0 > 14.0.0
- Provide expected converse emojis file
- Include lrexlib-oniguruma dependency


### Peertube-plugin-logo-framasoft

- Add update script
- 0.0.1 > 0-unstable-2025-05-30


### Peertube-plugin-matomo

- Add update script


### Peertube-plugin-privacy-remover

- Add upadate script
- 0.0.1 > 0-unstable-2025-05-30


### Peertube-plugin-transcoding-custom-quality

- Add update script
- 0.1.0 > 0-unstable-2025-05-30


### Peertube-plugin-transcoding-profile-debug

- Add update script


### Peertube-plugin-video-annotation

- Add update script
- 0.0.8 > 0-unstable-2025-05-30


### Peertube-theme-background-red

- Add update script


### Peertube-theme-dark

- Add update script
- 2.5.0 > 0-unstable-2025-05-30


### Peertube-theme-framasoft

- Add update script
- 0.0.1 > 0-unstable-2025-05-30


### Peettube-plugin-akismet

- Add update script


### Pkgs/libervia-backend

- Disable tests for lxml-html-clean


### Pkgs/openxc7

- 0.8.2-unstable-2025-03-14 -> 0.8.2-unstable-2025-04-03
- Mark as broken


### Projects

- Refactor demos to the demo type
- Re-enable binary artefacts
- Accept additional args


### Projects/Draupnir

- Expose
- Add basic example
- Add demo vm


### Projects/Ethersync

- Init
- Test syncing and neovim plugin
- Disable ssh backdoor for tests
- Support demo-shell


### Projects/NodeBB

- Init
- Init module and add basic example
- Add option enableLocalDB
- Add demo vm


### Projects/OpenWebCalendar

- Add basic example
- Add demo vm


### Projects/PeerTube

- Add peertube-cli (#1142)
- Split off livechat test


### Projects/holo

- Init (#1153)


### Projects/jaq

- Init (#1157)


### Projects/nyxt

- Init


### Seppo

- Implement project metadata


### Steamworks-pulleyback

- Use cmakeFlags instead of calling CMake manually


### Templates

- Add Spike
- Add derivation update task
- Add derivation packaging task
- Add example and demo tasks
- Refactors
- Refactor derivation updates


### Treewide

- Use moduleLocFromOptionString to locate re-exported modules
- Use pkgs.nixosTests for exported tests
- Use module attribute in tests
- Mark broken project tests with problem type


### Xrsh

- Implement project metadata
- Implement xrsh program (#1093)
- Add shell demo (#1118)


### Xrsh/demo-shell

- Remove hardcoded env variable


## 25.05 - 2025-05-30

### Bug Fixes

- Declare submodule attributes in options
- Access types recursively in types.nix
- Use deferredModule
- Modules for services and programs
- Add name option for programs


### CI

- Move NIX_CONFIG into workflow YAML


### CI/CD

- *test-demo-vm* Add ubuntu 25.04 to test matrix
- Add VM test-demo workflow (#719)
- Use branch's ngipkgs when testing demo


### Documentation

- Add usage instructions for overview's devmode


### Overview

- Fix a hard coded prefix for model options
- Move optionsDoc to default.nix
- Add devmode
- Don't load copy button when JS is disabled
- Show tags for projects with a demo
- Compare output between typing system
- Implement project list item as a module
- Implement the whole project list using modules (#1051)


### Vula

- Fix option name in example description
- Mark test as broken


### Cryptpad

- Fix demo port forwarding


### Demo

- Refactor vm config
- Init app-shell; separate vm and shell functions


### Heads

- Fix hash


### Hyperbeam

- Remove derivation


### Infra/secrets

- Update Cachix token


### Livervia-backend

- Remove unused deps


### Mitmproxy

- Use app-shell


### Models

- Add subgrant type (#988)
- Add link. library and binary types (#989)
- Add test and example types  (#985)
- Add service type  (#986)
- Add program type (#987)
- Init typing with module system


### Modules

- Move projects to types
- Cleanup custom types
- Refactor metadata type
- Re-order options
- Distinguish between custom and nixpkgs types


### Projects/types

- Fixup (#994)


### {xeddsa,libxeddsa}

- Remove derivations


## 25.04 - 2025-04-29

### Agorakit

- Projects-old -> projects


### Alive2

- Projects-old -> projects


### Briar

- Add metadata


### CNSPRCY

- Projects-old -> projects


### CONTRIBUTING

- Add public Matrix room


### Canaille

- Projects-old -> projects


### Cryptpad

- Refactor demo; add openPorts option


### DMT-Core

- Projects-old -> projects


### Documentation

- Add instructions for exposing a project


### Dokieli

- Projects-old -> projects


### Flake

- Don't check examples


### Flarum

- Projects-old -> Projects (#779)
- Delete old project entry


### Forgejo

- Projects-old -> projects


### GNUTaler

- Projects-old -> projects


### Galene

- Add project (#716)


### Gancio

- Move from projects-old to projects


### Heads

- Add project metadata & VM test
- Provide option to override allowlist of boards, symlink all allowed boards' ROMs
- Add more details about where images end up, and how they're named


### Hypermachines

- Projects-old -> projects


### Inko

- Projects-old -> projects


### KiKit

- Projects-old -> projects


### Liberaforms

- Projects-old -> projects
- Extract test config into separate example


### LibreSOC

- Projects-old -> projects


### Librecast

- Projects-old -> projects


### Meta-Presses

- Projects-old -> projects


### Misskey

- Projects-old -> Projects (#798)


### Naja

- Projects-old -> projects


### Nitrokey

- Projects-old -> projects


### Omnom

- Remove form projects-old


### Overview

- Fix wording (#636)
- Remove packages
- Move to `overview`
- Render service demos (#668)
- Provide download and copy buttons for demo code (#962)


### PeerTube

- Projects-old -> projects


### Pixelfed

- Projects-old -> projects


### Pretalx

- Projects-old -> projects


### Rosenpass

- Projects-old -> projects (#786)


### SCION

- Projects-old -> projects (#715)


### Servo

- Projects-old -> projects


### Stract

- Projects-old -> projects


### Vula

- Projects-old -> projects


### Wireguard

- Projects-old -> projects


### Anastasis

- 0.6.1 -> 0.6.1-unstable-2025-03-02


### Arpa2

- Projects-old -> projects


### Autobase

- 1.0.0-alpha.9 -> 7.2.2 (#707)


### Corestore

- 7.0.23 -> 7.1.0


### Gnunet

- Projects-old -> projects (#750)


### Gnunet-messenger-cli

- 0.3.0-unstable-2025-01-07 -> 0.3.1


### Heads

- Expose function to override allowList
- Acknowledge unmaintained & untested boards


### Heads.*

- Init at 0.2.1-unstable-2025-04-03


### Holo-cli

- Init at 0.4.0-unstable-2025-04-01


### Holod

- Init at 0.7.0


### Hyperbeam

- 3.0.1 -> 3.0.2


### Hyperblobs

- 2.3.3 -> 2.8.0


### Hypercore

- 10.28.11 -> 11.1.2 (#710)


### Hyperswarm

- 4.7.3 -> 4.11.1 (#921)


### Kbin

- Projects-old -> projects


### Lib

- Add moduleLocFromOptionString (#857)


### Lib25519

- Projects-old -> projects


### Libervia-backend

- Relax dependencies


### Libgnunetchat

- 0.5.0-unstable-2025-01-07 -> 0.5.3


### Libresoc

- Recythonize (#801)


### Libresoc-nmigen

- Use fetchCargoVendor
- Python39 -> python3
- Add build-system; set pyproject
- Add modgrammar
- Drop package overrides


### MCaptcha

- Projects-old -> Projects (#817)


### Makemake

- Setup CryptPad service on Caddy and host (#858)


### Metrics

- Move to maintainers
- Remove `with lib;`


### Mitmproxy

- Projects-old -> projects


### Models

- Add subgrant type


### Ntpd-rs

- Projects-old -> projects (#832)


### Proximity-matcher

- Init at 0-unstable-2023-12-23
- Add project


### Taldir

- 1.0.3 -> 1.0.5


### Tslib

- Projects-old -> projects


### Twister

- Fix build


### Wireguard-rs

- Update cargo lock


## 25.03 - 2025-03-28

### Aerogramme

- Migrate to new project structure
- Fix module option (#566)


### AtomicData

- Migrate to new project structure
- Fix test


### Bug Fixes

- Change example module type to path
- Top-level examples and tests not being mapped


### CI/CD

- Add templates to check


### CryptoLyzer

- Fix test


### Cryptpad

- Move to projects
- Add example and test (#661)


### Forgejo

- Use nixos tests


### Libervia-backend

- Extract from old Libervia, add to new project structure (#559)


### MarginaliaSearch

- Wait for X before launching FF in test
- Projects-old/ -> projects/


### Mastodon

- Introduce module and test from Nixpkgs


### Omnom

- Move from projects-old/ to projects/


### OpenWebCalendar

- Move from projects-old into projects


### Openfire

- Move projects-old/ -> projects


### Overview

- Stable project urls (#570)
- Render subgrant names if they exist in the new project model (#581)
- Mark as experimental, add more information (#603)
- Render project summary, basic styling (#627)
- Don't escape option descriptions (#632)
- Better rendering for subgrants (#633)
- Use IBM Plex Mono for monospace applications instead of letting the browser choose
- Redesign options rendering with focus on cognitive hierarchy
- Only ever generate html, remove pandoc as dependency (#673)
- Don't render default fields when there is no default
- Rebuild the rendering flow so that we can use markdown strings (#684)
- Render project snippets with deliverable type and summary text (#685)
- Signify readonly options
- Provide Open Graph information for link previews
- Fix font URLs


### Re-Isearch

- Add a VM test (#586)


### Atomic-server

- Use finalAttrs


### Atomic-{browser,cli,server}

- 0.39.0 -> 0.40.0


### Libervia-backend

- Relax pyopenssl


### Libresoc-nmigen

- Override tomli


### Makemake

- Enable prometheus node exporter
- Make contributors admins on buildbot


### Marginalia-search

- Build slop from source during the build


### Meta-press

- 1.8.17.1 -> 1.8.17.4


### Models

- Add binary type, make nixos modules optional
- Add top-level links


### OpenXC7

- Import upstream packages, add project (#616)


### Openfire

- 4.9.0 -> 4.9.2


### Taldir

- 0-unstable-2024-02-18 -> 1.0.3


## 25.02 - 2025-02-25

### Marginalia

- Remove "packages"
- Expand description on basic example


### Flake

- Change passthru tests so they're unique


### Makemake

- Add summer.nixos.org site and redirects (#476)


### Marginalia-search

- 24.10.0-unstable-2025-02-15


<!-- generated by git-cliff -->
