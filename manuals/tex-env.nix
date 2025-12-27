{
  texlive,
  extraTexPackages ? { },
}:
(texlive.combine (
  {
    #inherit (texlive) scheme-small;
    inherit (texlive)
      scheme-basic
      collection-fontsrecommended
      #collection-langfrench
      collection-latexrecommended
      collection-luatex
      environ
      tcolorbox
      titling

      amsmath
      atbegshi
      atveryend
      bitset
      capt-of
      cmap
      colortbl
      ellipse
      etexcmds
      etoolbox
      fancyvrb
      float
      fncychap
      fontspec
      framed
      geometry
      gettitlestring
      hopatch
      hycolor
      hypcap
      hyperref
      iftex
      infwarerr
      intcalc
      kvdefinekeys
      kvoptions
      kvsetkeys
      letltxmacro
      ltxcmds
      minitoc
      needspace
      ntheorem
      parskip
      pdfescape
      pdftexcmds
      pict2e
      polyglossia
      refcount
      rerunfilecheck
      stringenc
      tabulary
      titlesec
      uniquecounter
      upquote
      url
      varwidth
      wrapfig
      xcolor
      ;

  }
  // extraTexPackages
))
