# Generated with tex2nix 0.0.0
{
  texlive,
  extraTexPackages ? { },
}:
(texlive.combine (
  {
    inherit (texlive) scheme-small;
    "amsmath" = texlive."amsmath";
    "atbegshi" = texlive."atbegshi";
    "auxhook" = texlive."auxhook";
    "bidi" = texlive."bidi";
    "bigintcalc" = texlive."bigintcalc";
    "bitset" = texlive."bitset";
    "booktabs" = texlive."booktabs";
    "capt-of" = texlive."capt-of";
    "changepage" = texlive."changepage";
    "cmap" = texlive."cmap";
    "colortbl" = texlive."colortbl";
    "ctablestack" = texlive."ctablestack";
    "etex" = texlive."etex";
    "etexcmds" = texlive."etexcmds";
    "etoolbox" = texlive."etoolbox";
    "fancyhdr" = texlive."fancyhdr";
    "fancyvrb" = texlive."fancyvrb";
    "float" = texlive."float";
    "fncychap" = texlive."fncychap";
    "fontspec" = texlive."fontspec";
    "footmisc" = texlive."footmisc";
    "framed" = texlive."framed";
    "geometry" = texlive."geometry";
    "gettitlestring" = texlive."gettitlestring";
    "hopatch" = texlive."hopatch";
    "hycolor" = texlive."hycolor";
    "hypcap" = texlive."hypcap";
    "hyperref" = texlive."hyperref";
    "ifmtarg" = texlive."ifmtarg";
    "iftex" = texlive."iftex";
    "infwarerr" = texlive."infwarerr";
    "intcalc" = texlive."intcalc";
    "kvdefinekeys" = texlive."kvdefinekeys";
    "kvoptions" = texlive."kvoptions";
    "kvsetkeys" = texlive."kvsetkeys";
    "letltxmacro" = texlive."letltxmacro";
    "listings" = texlive."listings";
    "ltxcmds" = texlive."ltxcmds";
    "luabidi" = texlive."luabidi";
    "luacode" = texlive."luacode";
    "luaotfload" = texlive."luaotfload";
    "luatexbase" = texlive."luatexbase";
    "luavlna" = texlive."luavlna";
    "marvosym" = texlive."marvosym";
    "minitoc" = texlive."minitoc";
    "natbib" = texlive."natbib";
    "needspace" = texlive."needspace";
    "notoccite" = texlive."notoccite";
    "ntheorem" = texlive."ntheorem";
    "paralist" = texlive."paralist";
    "parskip" = texlive."parskip";
    "pdfescape" = texlive."pdfescape";
    "pdftexcmds" = texlive."pdftexcmds";
    "placeins" = texlive."placeins";
    "polyglossia" = texlive."polyglossia";
    "ragged2e" = texlive."ragged2e";
    "refcount" = texlive."refcount";
    "rerunfilecheck" = texlive."rerunfilecheck";
    "setspace" = texlive."setspace";
    "showexpl" = texlive."showexpl";
    "stringenc" = texlive."stringenc";
    "tabulary" = texlive."tabulary";
    "tex4ht" = texlive."tex4ht";
    "titlesec" = texlive."titlesec";
    "uniquecounter" = texlive."uniquecounter";
    "upquote" = texlive."upquote";
    "url" = texlive."url";
    "varwidth" = texlive."varwidth";
    "wrapfig" = texlive."wrapfig";
    "xcolor" = texlive."xcolor";
    "xifthen" = texlive."xifthen";
    "xurl" = texlive."xurl";

  }
  // extraTexPackages
))
