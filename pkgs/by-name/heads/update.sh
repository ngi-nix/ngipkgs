shopt -s inherit_errexit

set -x

[ "${storeDir}" = "" ] && { echo "Missing variable: storeDir" >&2 && exit 1; }
[ "${printHeadsVariablesMakefile}" = "" ] && { echo "Missing variable: printHeadsVariablesMakefile" >&2 && exit 1; }
[ "${printMuslCrossMakeVariablesMakefile}" = "" ] && { echo "Missing variable: printMuslCrossMakeVariablesMakefile" >&2 && exit 1; }

srcDir="$(nix --extra-experimental-features "nix-command flakes" build --no-link --print-out-paths .#heads.qemu-coreboot-fbwhiptail-tpm1-hotp.src)"
tmpDir="$(mktemp -d)"

headsDir="$(dirname "$(nix --extra-experimental-features "nix-command flakes" eval --raw .#heads.qemu-coreboot-fbwhiptail-tpm1-hotp.meta.position | cut -d':' -f1)")"
# If absolute in store, make relative. We want to overwrite deps.nix down the line
if [[ "$headsDir" == "$storeDir"* ]]; then
  storePrefix="$(echo "$headsDir" | grep -o "^${storeDir}/.*-source/")"
  headsDir="${headsDir#"$storePrefix"}"
fi

# Re-used template(s)
cat <<EOF >"$tmpDir"/package-template.nix
{
  name = "\${name}";
  url = "\${url}";
  hash = "\${hash}";
}
EOF

# Temp locations for generated Nix code
boardsTmpFile="$tmpDir"/boards.nix
modulesTmpFile="$tmpDir"/modules.nix
packagesTmpFile="$tmpDir"/packages.nix
muslCrossMakeTmpFile="$tmpDir"/musl-cross-make.nix

crossgccTmpFile="$tmpDir"/crossgcc.nix

echo "[" > "$boardsTmpFile"
echo "[" > "$modulesTmpFile"
echo "[" > "$packagesTmpFile"
echo "[" > "$muslCrossMakeTmpFile"

echo "{" > "$crossgccTmpFile"

# Find all properly supported boards, list their Makefile variables & combine them all
while IFS= read -r -d "" boardPath; do
  boardName="$(basename "$boardPath")"

  echo "\"${boardName}\"" >> "$boardsTmpFile"

  make -f ${printHeadsVariablesMakefile} \
    src="$srcDir" \
    BOARD="$boardName" \
  >> "$tmpDir"/board-"$boardName".txt
done < <(find "$srcDir"/boards -mindepth 1 -maxdepth 1 -print0 | sort -z)
cat "$tmpDir"/board-* | sort | uniq > "$tmpDir"/all.txt

# Functions to make some things less redundant
# Let functions check that they received correct amount of args
checkArgCount() {
  # Check own args
  if [ $# -ne 3 ]; then
    echo "Invalid argument count to ${FUNCNAME[0]}: Expected 3, got $#!" >&2
    exit 1
  fi

  callingFunctionName="$1"
  desiredArgCount="$2"
  actualArgCount="$3"

  if [ "$desiredArgCount" -ne "$actualArgCount" ]; then
    echo "Invalid argument count to ${callingFunctionName}: Expected ${desiredArgCount}, got ${actualArgCount}!" >&2
    exit 1
  fi
}

# Certain URLs just don't work (inconsistent results, permanently dead)
# This will apply some replacements to such URLs, in an effort to make fetching results more consistent
fixUrl() {
  checkArgCount "${FUNCNAME[0]}" 1 "$#"

  fixedUrl="$1"

  # ftpmirror.gnu.org sends us through mirror roulette, but some mirrors seem misconfigured and cause nix-prefetch-url
  # to save a .tar file instead of the original .tar.gz
  # Current hypothesis: headers content-type=application/x-gzip + content-encoding=x-gzip make Nix unzip the archive
  # For example: mirror.checkdomain.de
  # For this reason, we can't rely on it, and need to use GNU's main server - response times be damned
  #
  # Some URLs have /gnu/ already included, others need it added in.
  fixedUrl="${fixedUrl/#"https://ftpmirror.gnu.org/gnu"/"https://ftp.gnu.org/gnu"}"
  fixedUrl="${fixedUrl/#"https://ftpmirror.gnu.org"/"https://ftp.gnu.org/gnu"}"

  # Old acpica sources are painful, Intel downloadmirror gives access denied for acpica-unix2-20220331
  # This source mirror is used for other versions, don't know why upstream isn't using it for this one as well
  fixedUrl="${fixedUrl/#"https://downloadmirror.intel.com/774879"/"https://mirror.math.princeton.edu/pub/libreboot/misc/acpica"}"

  echo "$fixedUrl"
}

# nix-prefetch-url doesn't give us a nice SRI hash
# This will run the resulting hash through nix hash (convert) to print an SRI one
getSriHash() {
  checkArgCount "${FUNCNAME[0]}" 1 "$#"

  url="$1"

  # In case of temporary gnu.org failure, let's not loose tons of progress - a human can re-attempt this manually
  hashRaw="$(nix-prefetch-url "$url" --type sha256 || true)"
  if [ "x" != "x${hashRaw}" ]; then
    nix --extra-experimental-features nix-command hash convert --from nix32 --hash-algo sha256 --to sri "$hashRaw"
  fi
}

# Given a package name, url & hash, substitute them into a template for a downloaded file and add the resulting
# attrset to a file
addPackageDefinition() {
  checkArgCount "${FUNCNAME[0]}" 4 "$#"

  packageName="$1"
  packageUrl="$2"
  packageHash="$3"
  appendToFile="$4"

  {
    export name="$packageName"
    export url="$packageUrl"
    export hash="$packageHash"
    envsubst < "$tmpDir"/package-template.nix
  } >> "$appendToFile"
}

# Given the name of a coreboot version & the path to its cloned/unpacked root dir, collect all crossgcc dependencies
# that it specifies and add them as necessary downloads (specific to that coreboot version)
collectCorebootCrossgccDeps() {
  checkArgCount "${FUNCNAME[0]}" 3 "$#"

  corebootName="$1"
  corebootSrc="$2"
  appendToFile="$3"

  # If there are patches available, apply them. They may affect download URLs
  corebootPatchesDir="${srcDir}/patches/${corebootName}"
  if [ -d "${corebootPatchesDir}" ]; then
    # Need to apply changes to src, so need modifiable version
    modifiableCorebootSrc="${tmpDir}/${corebootName}"
    cp -r "$corebootSrc" "$modifiableCorebootSrc"
    chmod -R +w "$modifiableCorebootSrc"
    corebootSrc="$modifiableCorebootSrc"

    # Apply all found patch files
    pushd "$corebootSrc"
    for patch in "${corebootPatchesDir}"/*; do
      git apply --verbose --reject --binary < "$patch"
    done
    popd
  fi

  crossgccSrc="$corebootSrc"/util/crossgcc/buildgcc

  echo "\"${corebootName}\" = [" >> "$appendToFile"

  while IFS= read -r -d ' ' crossgccDepUrl; do
    crossgccDepArchive="$(basename "$crossgccDepUrl")"

    if [ "$crossgccDepArchive" == "acpica-unix2-20220331.tar.gz" ]; then
      echo "Skipping due to no known safe mirror: ${crossgccDepArchive}"
      echo "
        # Skipping ${crossgccDepArchive} because we don't have a known-good mirror
        # Candidate (Heads explicitly *doesn't* use this one for this version): https://mirror.math.princeton.edu/pub/libreboot/misc/acpica/acpica-unix2-20220331.tar.gz
        # Candidate (involves an archive rename): https://distfiles.macports.org/acpica/acpica-unix-20220331.tar.gz
      " >> "$appendToFile"
    else
      echo "Handling ${corebootName} crossgcc package: ${crossgccDepArchive}"

      # Apply some common URL fixes
      crossGccDepUrl="$(fixUrl "$crossgccDepUrl")"

      # nix-prefetch-url doesn't give the hash in SRI format :(
      crossgccDepHash="$(getSriHash "$crossGccDepUrl")"

      addPackageDefinition "coreboot-crossgcc-${crossgccDepArchive}" "$crossGccDepUrl" "$crossgccDepHash" "$appendToFile"
    fi
  done < <(echo "$(env CROSSGCC_VERSION="$corebootName" "$crossgccSrc" --urls) " | tr -d '\t') # CROSSGCC_VERSION so git isn't invoked, trailing space for read to get last entry

  echo "];" >> "$appendToFile"
}

# Handle defined modules (repos that need to be cloned)
while IFS= read -r moduleRepo; do
  module="$(basename "$moduleRepo" _repo)"

  echo "Handling module: ${module}"

  repo="$(grep -w "^${module}_repo =" "$tmpDir"/all.txt | cut -d' ' -f3-)"

  # Some modules, like linuxboot, do not request a specific version
  isPinned="false"
  commitHash=""
  if grep -w "^${module}_commit_hash =" "$tmpDir"/all.txt > /dev/null; then
    isPinned="true"
    commitHash="$(grep -w "^${module}_commit_hash =" "$tmpDir"/all.txt | cut -d' ' -f3-)"
  fi

  nix-prefetch-git "$repo" "$commitHash" --fetch-submodules > "$tmpDir"/"$module".nix-prefetch-git
  nixCommitHash="$(jq -r '.rev' "$tmpDir"/"$module".nix-prefetch-git)"
  nixHash="$(jq -r '.hash' "$tmpDir"/"$module".nix-prefetch-git)"

  echo "{
    name = \"${module}\";
    url = \"${repo}\";
    pinned = ${isPinned};
    rev = \"${nixCommitHash}\";
    hash = \"${nixHash}\";
  }" >> "$modulesTmpFile"

  # If coreboot, also collect the crossgcc deps
  if [[ "$module" == coreboot-* && "$module" != coreboot-blobs-* ]]; then
    collectCorebootCrossgccDeps "$module" "$(jq -r '.path' "$tmpDir"/"$module".nix-prefetch-git)" "$crossgccTmpFile"
  fi
done < <(grep -wo '^.*_repo' "$tmpDir"/all.txt)

# Handle packages (mostly tarball downloads)
while IFS= read -r packageVersion; do
  package="$(basename "$packageVersion" _version)"

  # Modules are only differenciated by having _repo values, need to sort those out
  if grep -w "^${package}_repo =" "$tmpDir"/all.txt > /dev/null; then
    echo "Skipping non-package module: ${package}"
    continue
  fi

  # Special case: linux_patch_version is not a package - it overrides the version part when looking up the patches for
  # the corresponding kernel build, for example to only apply some patches for specific platform
  # (Example: openpower boards fetch the linux-${version} srcs, but apply patches from linux-${version}-openpower)
  if [ "$package" == "linux_patch" ]; then
    echo "Skipping non-package entry: ${package}"
    continue
  fi

  # coreboot-blobs entries for coreboot modules are invalid
  if [[ "$package" == coreboot-blobs-* ]]; then
    if grep -w "^coreboot-${package#"coreboot-blobs-"}_repo =" "$tmpDir"/all.txt > /dev/null; then
      echo "Skipping non-existent coreboot-blobs package (corresponding coreboot version is a module): ${package}"
      continue
    fi
  fi

  # These pull in expat 2.2.7, whose download link was broken by the expat team because it is a security vulnerability
  # See https://sourceforge.net/projects/expat/files/expat/2.2.7/
  # Can skip their blobs as well, since they'll never get used
  if [[ "$package" == "coreboot-4.11" || "$package" == "coreboot-blobs-4.11" ]]; then
    echo "Skipping insecure package: ${package}"
    continue
  fi

  echo "Handling package: ${package}"

  # Linux kernel packages all have the same variable name, importing a different board may define different values
  # Check how many matches we have, iterate through them

  while IFS= read -r archiveName; do
    archiveUrl="$(grep -w "^${package}_url =" "$tmpDir"/all.txt | cut -d' ' -f3-)"

    # If there are multiple URLs for packages with this name, take the one that has the archiveName.
    # TODO: Handle situations:
    # - Multiple URLs, none contain the archiveName
    # - Multiple URLs,multiple contain the archiveName
    if [ "$(echo "${archiveUrl}" | wc -l)" -ne 1 ]; then
      if [[ "$(echo "${archiveUrl}" | grep "${archiveName}$")" != "" && "$(echo "${archiveUrl}" | grep -c "${archiveName}$")" -eq 1 ]]; then
        archiveUrl="$(echo "${archiveUrl}" | grep "${archiveName}$")"
      else
        echo "Cannot handle multi-URL situation: Failed to find exactly one ${archiveName} in: ${archiveUrl}" >&2
        exit 1
      fi
    fi

    # Download url from qrencode's website url is currently borked, get it from the internet archive
    if [ "$package" = "qrencode" ]; then
      archiveVersion="$(grep -w "^${package}_version =" "$tmpDir"/all.txt | cut -d' ' -f3-)"
      archiveUrl="https://web.archive.org/web/20240910005455/https://fukuchi.org/works/qrencode/qrencode-${archiveVersion}.tar.gz"
    fi

    # Apply some common URL fixes
    archiveUrl="$(fixUrl "$archiveUrl")"

    # nix-prefetch-url doesn't give the hash in SRI format :(
    archiveHash="$(getSriHash "$archiveUrl")"

    addPackageDefinition "$archiveName" "$archiveUrl" "$archiveHash" "$packagesTmpFile"

    # If coreboot package, get corresponding crossgcc packages
    if [[ "$package" == coreboot-* && "$package" != coreboot-blobs-* ]]; then
      archiveLocation="$(nix-prefetch-url "$archiveUrl" "$archiveHash" --type sha256 --print-path | tail -n1)"
      corebootSrcTmp="$(mktemp -d -p "$tmpDir")"
      xzcat "$archiveLocation" | tar -C "$corebootSrcTmp" -xf-

      corebootSrc="$(find "$corebootSrcTmp" -path '*/util/crossgcc/buildgcc' | sort | head -n1)"
      corebootSrc="${corebootSrc%"/util/crossgcc/buildgcc"}"

      collectCorebootCrossgccDeps "$package" "$corebootSrc" "$crossgccTmpFile"
    fi

    # If musl-cross-make, get corresponding musl-cross-make packages
    if [ "$package" = "musl-cross-make" ]; then
      archiveLocation="$(nix-prefetch-url "$archiveUrl" "$archiveHash" --type sha256 --print-path | tail -n1)"
      muslCrossMakeSrcTmp="$(mktemp -d -p "$tmpDir")"
      gunzip -ck "$archiveLocation" | tar -C "$muslCrossMakeSrcTmp" -xf-

      muslCrossMakeSrc="$(find "$muslCrossMakeSrcTmp" -maxdepth 2 -name "Makefile" | sort | head -n1)"
      muslCrossMakeSrc="${muslCrossMakeSrc%"/Makefile"}"

      make -f ${printMuslCrossMakeVariablesMakefile} \
        src="$muslCrossMakeSrc" \
      | sort | uniq >> "$tmpDir"/musl-cross-make.txt

      # config.sub has entirely different format
      {
        echo "Handling musl-cross-make package: CONFIG_SUB"

        configSubVersion="$(grep -w "^CONFIG_SUB_REV =" "$tmpDir"/musl-cross-make.txt | cut -d' ' -f3-)"
        configSubUrl="https://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=${configSubVersion}"

        # nix-prefetch-url doesn't give the hash in SRI format :(
        # Need to override name, contains illegal ";"
        # In case of temporary gnu.org failure, let's not loose tons of progress - a human can re-attempt this manually
        configSubHashRaw="$(nix-prefetch-url "$configSubUrl" --type sha256 --name "config.sub" || true)"
        configSubHash=""
        if [ "x" != "x${configSubHashRaw}" ]; then
          configSubHash="$(nix --extra-experimental-features nix-command hash convert --from nix32 --hash-algo sha256 --to sri "$configSubHashRaw")"
        fi

        addPackageDefinition "config.sub" "$configSubUrl" "$configSubHash" "$muslCrossMakeTmpFile"
      }

      while IFS= read -r muslCrossMakeDepVersion; do
        muslCrossMakeDep="$(basename "$muslCrossMakeDepVersion" "_VER")"

        echo "Handling musl-cross-make package: ${muslCrossMakeDep}"

        muslCrossMakeDepVer="$(grep -w "^${muslCrossMakeDep}_VER =" "$tmpDir"/musl-cross-make.txt | cut -d' ' -f3-)"
        muslCrossMakeDepSite="$(grep -w "^${muslCrossMakeDep}_SITE =" "$tmpDir"/musl-cross-make.txt | cut -d' ' -f3-)"
        muslCrossMakeDepArchive="$(basename "$(find "$muslCrossMakeSrc"/hashes -name "${muslCrossMakeDep@L}-${muslCrossMakeDepVer}.*" | sort | head -n1)" ".sha1")"

        if [[ "$muslCrossMakeDep" == "LINUX" && "$muslCrossMakeDepVer" == headers-* ]]; then
          # Linux headers live at different site
          muslCrossMakeDepSite="$(grep -w "^${muslCrossMakeDep}_HEADERS_SITE =" "$tmpDir"/musl-cross-make.txt | cut -d' ' -f3-)"
        elif [[ "$muslCrossMakeDep" == "GCC" ]]; then
          # GCCs (except *really* old ones) live in separate subdirs
          muslCrossMakeDepSite="${muslCrossMakeDepSite}/gcc-${muslCrossMakeDepVer}"
        fi

        muslCrossMakeDepUrl="${muslCrossMakeDepSite}/${muslCrossMakeDepArchive}"

        # Apply some common URL fixes
        muslCrossMakeDepUrl="$(fixUrl "$muslCrossMakeDepUrl")"

        # nix-prefetch-url doesn't give the hash in SRI format :(
        muslCrossMakeDepHash="$(getSriHash "$muslCrossMakeDepUrl")"

        addPackageDefinition "$muslCrossMakeDepArchive" "$muslCrossMakeDepUrl" "$muslCrossMakeDepHash" "$muslCrossMakeTmpFile"
      done < <(grep -wo '^.*_VER' "$tmpDir"/musl-cross-make.txt)
    fi
  done < <(grep -w "^${package}_tar =" "$tmpDir"/all.txt | cut -d' ' -f3-)
done < <(grep -wo '^.*_version' "$tmpDir"/all.txt | uniq)

echo "]" >> "$boardsTmpFile"
echo "]" >> "$modulesTmpFile"
echo "]" >> "$packagesTmpFile"
echo "]" >> "$muslCrossMakeTmpFile"

echo "}" >> "$crossgccTmpFile"

# Collect the generated data
depsTmpFile="$tmpDir"/deps.nix
{
  cat <<EOF
# This file has been autogenerated.
# Update by running the updateScript.
# Note that some sections may not be supported by the updateScript yet, so
# please check the diff of the resulting file.
{
  boards =
EOF
  cat "$boardsTmpFile"
  cat <<EOF
;
  modules =
EOF
  cat "$modulesTmpFile"
  cat <<EOF
;
  pkgs =
EOF
  cat "$packagesTmpFile"
  cat <<EOF
;
  crossgcc-deps =
EOF
  cat "$crossgccTmpFile"
  cat <<EOF
;
  musl-cross-make-deps =
EOF
  cat "$muslCrossMakeTmpFile"
  cat <<EOF
;
}
EOF
} > "$tmpDir"/deps.nix

# Format & apply new data
nixfmt "$depsTmpFile"
mv "$depsTmpFile" "$headsDir"/deps.nix

# If everything went well, we can delete all the temporary data
rm -r "$tmpDir"
