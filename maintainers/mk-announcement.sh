#!/usr/bin/env bash
set -euo pipefail

NAME="<PROJECT_NAME>"

while (( $# )); do
    case "$1" in
        -n|--name) NAME="$2"; shift 2 ;;
        *) shift ;;
    esac
done

json_content=$(cat)

summary=$(jq -r '.metadata.summary as $s | ($s[0:1] | ascii_downcase) + $s[1:]' <<<"$json_content")
homepage_url=$(jq -r '.metadata.links.homepage.url' <<<"$json_content")

mapfile -t grants < <(jq -r '.metadata.subgrants | keys[]' <<<"$json_content")
grant_str=$(IFS=, ; echo "${grants[*]}")

cat <<EOF
# Discourse post

Title: [Nix@NGI] $NAME packaged for NGIpkgs

[**$NAME**]($homepage_url) is a $summary. This project is funded by the NGI0 $grant_str grant(s).

<WHAT_CAN_PEOPLE_DO_WITH_IT>

<OTHER_COMMENTS> <THANKS_PEOPLE_INVOLVED>

<LINK_TO_TRACKING_ISSUE>
<LINK_TO_NIXPKGS_WORK>

### Try it out

Follow the [project instructions](https://ngi.nixos.org/project/$NAME/) to launch the $NAME demo in a virtual machine.

### Share your feedback

Please leave your feedback using this [short survey](<LINK_TO_SURVEY>), which will be available for the next 30 days (until the <ADD_ABSOLUTE_DATE>).

Alternatively, join the [office hours on Jitsi](https://jitsi.lassul.us/ngi-nix-office-hours) every [Tuesday and Thursday from 15:00--16:00 CET/CEST](https://calendar.google.com/calendar/u/0/embed?src=b9o52fobqjak8oq8lfkhg3t0qg@group.calendar.google.com) and the [NGIpkgs Matrix channel](https://matrix.to/#/#ngipkgs:matrix.org) for any further comments or questions.

[Nix@NGI team webpage](https://nixos.org/community/teams/ngi/).

---

# Email to NLnet

\`\`\`text
Subject: [Nix@NGI] $NAME packaged for NGIpkgs

Body:

Dear NLnet Foundation staff,

We have completed the packaging tasks for the following project:
- Project: $NAME
- Project number: <ADD_PROJECT_NUMBER>
- Fund: $grant_str

The package is now available in the NGIpkgs repository: https://ngi.nixos.org/project/$NAME/.

Best regards
\`\`\`

---

# Email to project author

\`\`\`text
Subject: [Nix@NGI] $NAME packaged for NGIpkgs

Body:

Dear <PROJECT_AUTHOR>,

The Nix@NGI team is an NLnet partner for packaging NGI0 funded projects. We are happy to let you know that we have packaged $NAME for the NGIpkgs repository. You are invited to follow the project instructions: https://ngi.nixos.org/project/$NAME/, to launch the $NAME demo in a virtual machine.

Your input as the project author is very valuable for us. If you can, please leave your feedback using this short survey: <LINK_TO_SURVEY>, which will be available for the next 30 days.

For more information about Nix, see: https://nix.dev/.

The Nix@NGI team: https://nixos.org/community/teams/ngi/.

Kind regards
\`\`\`
EOF
