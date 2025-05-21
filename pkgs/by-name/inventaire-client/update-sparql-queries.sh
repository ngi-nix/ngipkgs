shopt -s inherit_errexit

set -x

[ "${storeDir}" = "" ] && { echo "Missing variable: storeDir" >&2 && exit 1; }
[ "${dumpUrlsJson}" = "" ] && { echo "Missing variable: dumpUrlsJson" >&2 && exit 1; }

srcDir="$(nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths .#inventaire-client.src)"
tmpDir="$(mktemp -d)"

inventaireClientDir="$(dirname "$(nix --extra-experimental-features "nix-command flakes" eval --raw .#inventaire-client.meta.position | cut -d':' -f1)")"
# If absolute in store, make relative. We want to overwrite a file down the line
if [[ "$inventaireClientDir" == "$storeDir"* ]]; then
  storePrefix="$(echo "$inventaireClientDir" | grep -o "^${storeDir}/.*-source/")"
  inventaireClientDir="${inventaireClientDir#"$storePrefix"}"
fi

# Temp locations
urlsDumpPath="$tmpDir"/urls.txt
jsonDumpsDir="$tmpDir"/sparql-queries

mkdir -p "$jsonDumpsDir"

cp -v --no-preserve=mode "${srcDir}"/scripts/sitemaps/queries.js "$tmpDir"/
cp -v --no-preserve=mode "${dumpUrlsJson}" "$tmpDir"/

env \
  HOME="$tmpDir" \
  sh -c 'cd ~ && npm install wikibase-sdk'

env \
  HOME="$tmpDir" \
  sh -c "cd ~ && node $(basename "${dumpUrlsJson}") > ${urlsDumpPath}"

while IFS= read -r urlDump; do
  name="$(echo "$urlDump" | cut -d'|' -f1)"
  url="$(echo "$urlDump" | cut -d'|' -f2)"

  sleep 10 # Let's be nice to wikidata.org, these can take awhile

  # Get query result
  curl \
    --user-agent 'NGIpkgs (https://github.com/ngi-nix/ngipkgs), for inventaire-client packaging' \
    -L "$url" \
    -o "$tmpDir"/"$name".json

  # Save compressed result
  gzip -9ck "$tmpDir"/"$name".json > "$jsonDumpsDir"/"$name".json.gz

  # Save the query URL, for checking that they match what the build would've fetched
  printf "%s" "$url" > "$jsonDumpsDir"/"$name".url
done < "$urlsDumpPath"

# Put new data into place
rm -vrf "$inventaireClientDir"/sparql-queries
mv -v "$jsonDumpsDir" "$inventaireClientDir"/sparql-queries

# If everything went well, we can delete all the temporary data
rm -r "$tmpDir"
