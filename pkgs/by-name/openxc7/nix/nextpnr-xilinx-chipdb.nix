{
  stdenv,
  nixpkgs,
  backend,
  nextpnr-xilinx,
  prjxray,
  pypy310,
  coreutils,
  findutils,
  gnused,
  gnugrep,
  ...
}:

stdenv.mkDerivation rec {
  pname = "nextpnr-xilinx-chipdb";
  version = nextpnr-xilinx.version;
  inherit backend;

  src = "${nextpnr-xilinx.outPath}/share/nextpnr/external/prjxray-db";
  # Don't try to unpack src, it already exists
  dontUnpack = true;

  buildInputs = [
    prjxray
    nextpnr-xilinx
    pypy310
    coreutils
    findutils
    gnused
    gnugrep
  ];
  buildPhase = ''
    mkdir -p $out
    find ${src}/ -type d -name "*-*" -mindepth 1 -maxdepth 2 |\
      sed -e 's,.*/\(.*\)-.*$,\1,g' -e 's,\./,,g' |\
      sort |\
      uniq >\
    $out/footprints.txt

    touch $out/built-footprints.txt

    for i in `cat $out/footprints.txt`
    do
        if   [[ $i = xc7a* ]]; then ARCH=artix7 
        elif [[ $i = xc7k* ]]; then ARCH=kintex7
        elif [[ $i = xc7s* ]]; then ARCH=spartan7
        elif [[ $i = xc7z* ]]; then ARCH=zynq7
        else 
          echo "unsupported architecture for footprint $i"
          exit 1
        fi

        if [[ $ARCH != "${backend}" ]]; then
          continue
        fi

        FIRST_SPEEDGRADE_DIR=`ls -d ${src}/$ARCH/$i-* | sort -n | head -1`
        FIRST_SPEEDGRADE=`echo $FIRST_SPEEDGRADE_DIR | tr '/' '\n' | tail -1`
        pypy3.10 ${nextpnr-xilinx}/share/nextpnr/python/bbaexport.py --device $FIRST_SPEEDGRADE --bba $i.bba 2>&1
        bbasm -l $i.bba $out/$i.bin
        echo $i >> $out/built-footprints.txt
    done

    mv -f $out/built-footprints.txt $out/footprints.txt

    # make the chipdb directory available
    mkdir -p $out/bin
    cat > $out/bin/get_chipdb_${backend}.sh <<EOF
    #!${nixpkgs.runtimeShell}
    echo -n $out
    EOF
    chmod 755 $out/bin/get_chipdb_${backend}.sh
  '';

  # TODO(jleightcap): the above buildPhase is adapated from a `builder`; which combines the process of
  # compiling assets along with installing those assets to `$out`.
  # These steps should be untangled, ideally - for now just use the buildPhase and disable the (empty)
  # installPhase.
  dontInstall = true;
}
