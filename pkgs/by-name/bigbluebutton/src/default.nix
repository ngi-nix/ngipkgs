{
  lib,
  fetchFromGitHub,
  runCommand,
}:

let
  # Defined as git clone commands in the *.placeholder.sh files in BBB root
  externalDeps = [
    {
      name = "bbb-etherpad";
      src = fetchFromGitHub {
        owner = "ether";
        repo = "etherpad-lite";
        tag = "1.9.4";
        hash = "sha256-xIwovBrEx9NMI5/v+p6YUAGbv9kMefCqJk+V8x38lvQ=";
      };
    }
    {
      name = "bbb-pads";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-pads";
        tag = "v1.5.3";
        hash = "sha256-9WFDk+a6oSr9kDsqTVWdLuz1PpkHIOeThnfcnvsUgFs=";
      };
    }
    {
      name = "bbb-playback";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-playback";
        tag = "v5.3.5";
        hash = "sha256-XoRQhw8dTRS0C5ZA8lUt6Xk63+h8BtzTPD3fKxriSbM=";
      };
    }
    # This is being fetched pre-built, prolly needs extra treatment for our from-source build
    {
      name = "bbb-presentation-video";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-presentation-video";
        tag = "5.0.0-rc.1";
        hash = "sha256-iGB8GIIvBYgKl87pQq6Dm7/r1jLN32EntiCBdKPXJ2Q=";
      };
    }
    {
      name = "bbb-transcription-controller";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-transcription-controller";
        tag = "v0.2.10";
        hash = "sha256-fRrLF9nKX13rkn/1fLoYSLyFNFu5Md1sOGMlPSvKu/c=";
      };
    }
    {
      name = "bbb-webhooks";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webhooks";
        tag = "v3.3.1";
        hash = "sha256-ggHBaT93wqf9TvofM+sQKospIJ+1vgiUjgRTBLXAS2U=";
      };
    }
    {
      name = "bbb-webrtc-recorder";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webrtc-recorder";
        tag = "v0.9.4";
        hash = "sha256-J1OxsWiVa1lRvTyhHDluM6RYZ9zHFNkNLGeDJe1BH6Y=";
      };
    }
    {
      name = "bbb-webrtc-sfu";
      src = fetchFromGitHub {
        owner = "bigbluebutton";
        repo = "bbb-webrtc-sfu";
        tag = "v2.19.0-beta.2";
        hash = "sha256-4GHbbSE7Sa9FsBpumlX4Xj3ls/cL1XZvUgKTzF3ifW8=";
      };
    }
    {
      name = "freeswitch";
      src = fetchFromGitHub {
        owner = "signalwire";
        repo = "freeswitch";
        tag = "v1.10.12";
        hash = "sha256-uOO+TpKjJkdjEp4nHzxcHtZOXqXzpkIF3dno1AX17d8=";
      };
    }
  ];
  srcBare = fetchFromGitHub {
    owner = "bigbluebutton";
    repo = "bigbluebutton";
    tag = "v3.0.10";
    hash = "sha256-r1s+5AFwBrbIUOC+zuWPWNWqiuzHWgBDrWV8JN5bNGM=";
  };
in
runCommand "bigbluebutton-src" { } ''
  cp -vr ${srcBare} $out
  chmod +w $out

  ${lib.strings.concatMapStringsSep "\n" (dep: "cp -vr ${dep.src} $out/${dep.name}") externalDeps}
''
