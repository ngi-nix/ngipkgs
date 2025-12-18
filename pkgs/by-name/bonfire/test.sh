#!/usr/bin/env nix
#! nix shell --impure --expr ``
#! nix let pkgs = import (builtins.getFlake "nixpkgs") {}; in
#! nix [
#! nix   pkgs.gitMinimal
#! nix   pkgs.nix-output-monitor
#! nix   pkgs.openssl
#! nix ]
#! nix ``
#! nix --command bash
set -eux
cd "${0%/*}"

root=$(git rev-parse --show-toplevel)
nom build -f "$root" bonfire

if [ -s .env ]; then source "$PWD"/.env; fi

secret() {
  if [ ! "$(eval "echo \${$1:+true}")" ]; then
    export "$1=$(openssl rand -hex "$2")"
    echo "export $1=$(eval "echo \$$1")" >>.env
  fi
}

secret RELEASE_COOKIE 40
secret ENCRYPTION_SALT 128
secret SIGNING_SALT 128
secret SECRET_KEY_BASE 128
secret POSTGRES_PASSWORD 25
secret MEILI_MASTER_KEY 25
#export DATABASE_URL=ecto://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost/$POSTGRES_DB
export TZDATA_DIR=/tmp/bonfire_tzdata

export FLAVOUR=social
export MIX_ENV=prod
export WITH_DOCKER=no

export POSTGRES_HOST=localhost
export POSTGRES_USER=bonfire
export POSTGRES_DB=bonfire

# Warning(maint/install):
# require a running postgresql server,
# not installed/configured by this script.
PSQL="sudo -u postgres psql"

if $PSQL -tAc "SELECT 1 FROM pg_catalog.pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1; then
  $PSQL -d template1 -AqtX --set ON_ERROR_STOP=1 -f - <<EOF
  DROP OWNED BY "$POSTGRES_USER";
  DROP DATABASE "$POSTGRES_DB";
  DROP ROLE "$POSTGRES_USER";
EOF
fi

$PSQL -d template1 -AqtX --set ON_ERROR_STOP=1 -f - <<EOF
CREATE ROLE "$POSTGRES_USER" NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD '$POSTGRES_PASSWORD';
CREATE DATABASE "$POSTGRES_DB" WITH OWNER="$POSTGRES_USER" ENCODING="UTF-8"
;
REVOKE ALL ON DATABASE "$POSTGRES_DB" FROM public;
GRANT ALL ON SCHEMA public TO "$POSTGRES_USER" WITH GRANT OPTION;
EOF

export DATABASE_URL=ecto://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST/$POSTGRES_DB
export TZDATA_DIR=/tmp/bonfire_tzdata

#just mix bonfire.sync_themes
#just setup-prod
#just rel-build
#just cmd _build/prod/rel/bonfire/bin/bonfire start

export HOSTNAME=localhost
export SERVER_PORT=4000
# port your visitors will access (typically 80 or 443, will be different than SERVER_PORT only if using a reverse proxy)
export PUBLIC_PORT=4000

# uncomment in order to NOT automatically change the database schema when you upgrade the app
# DISABLE_DB_AUTOMIGRATION=true

# max file upload size (default is 20 MB)
# in megabytes
export UPLOAD_LIMIT=20
export UPLOAD_LIMIT_IMAGES=5
export UPLOAD_LIMIT_VIDEOS=20

# Use cowboy or bandit as webserver?
export PLUG_SERVER=cowboy

# Enables other websites/apps to sign in using accounts on this Bonfire instance
export ENABLE_SSO_PROVIDER=true
# change to true only after initial migrations were run
export DB_MIGRATE_INDEXES_CONCURRENTLY=false

export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export ACME_AGREE=true
export REPLACE_OS_VARS=true

export LIVEVIEW_ENABLED=true
export WITH_API_GRAPHQL=0
export WITH_LV_NATIVE=0
export WITH_IMAGE_VIX=0
export WITH_AI=0
export SHOW_DEBUG_IN_DEV=true

# hostname and port of meili search index
export SEARCH_MEILI_INSTANCE=http://localhost:7700

# INVITE_KEY_EMAIL_CONFIRMATION_BYPASS=put-a-invite-key-to-bypass-email-confirmation-here

# what service to use for sending out emails (eg. smtp, mailgun, none) NOTE: you should also set the corresponding keys in secrets section
export MAIL_BACKEND=none
# edit with your email address and API key
# MAIL_KEY=
# MAIL_FROM=bonfire@example.com
# MAIL_DOMAIN=

# Uploads
# UPLOADS_S3_BUCKET=
# UPLOADS_S3_ACCESS_KEY_ID=
# UPLOADS_S3_SECRET_ACCESS_KEY=
# UPLOADS_S3_URL=
# ^ set UPLOADS_S3_URL to be the same UPLOADS_S3_BUCKET if you're using a custom CDN domain (the domain of which must match the bucket name)

# OpenID Connect: connect as a client to the OpenID Connect provider with callback url https://yourinstance.tld/oauth/client/openid_1
# OPENID_1_DISCOVERY=
# OPENID_1_DISPLAY_NAME=
# OPENID_1_CLIENT_ID=
# OPENID_1_CLIENT_SECRET=
# OPENID_1_SCOPE=
# OPENID_1_RESPONSE_TYPE=code
# ^ can be code, token or id_token

# orcid.org SSO: connect as a client to the orcid.org OpenID Connect provider with callback url https://yourinstance.tld/oauth/client/orcid
# ORCID_CLIENT_ID=
# ORCID_CLIENT_SECRET=

# OAuth2 provider: connect as a client to the OAuth2 provider with callback url https://yourinstance.tld/oauth/client/oauth_1
# OAUTH_1_DISPLAY_NAME=
# OAUTH_1_CLIENT_ID=
# OAUTH_1_CLIENT_SECRET=
# OAUTH_1_AUTHORIZE_URI=
# OAUTH_1_ACCESS_TOKEN_URI=
# OAUTH_1_USER_INFO_URI=

# github.com SSO: connect as a client to the github.com OAuth2 provider with callback url https://yourinstance.tld/oauth/client/github
# GITHUB_APP_CLIENT_ID=
# GITHUB_CLIENT_SECRET=

# telemetry API keys
# SENTRY_DSN=
export OTEL_ENABLED=0
# OTEL_HONEYCOMB_API_KEY=
# OTEL_LIGHTSTEP_API_KEY=

# default admin user if you generate seed data
export SEEDS_USER=root

# Bonfire extensions configs
export WEB_PUSH_SUBJECT=mailto:bonfire@example.com
# WEB_PUSH_PUBLIC_KEY=
# WEB_PUSH_PRIVATE_KEY=
# GEOLOCATE_OPENCAGEDATA=
export MAPBOX_API_KEY=pk.eyJ1IjoibWF5ZWwiLCJhIjoiY2tlMmxzNXF5MGFpaDJ0bzR2M29id2EzOCJ9.QsmjD-zypsE0_wonLGCYlA
# GITHUB_TOKEN=
# TX_TOKEN=
# AKISMET_API_KEY=

# For pando.ra integration
# PANDORA_URL=https://0xdb.org/

result/bin/bonfire start
