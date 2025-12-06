_: {
  flake.overlays = {
    default = _final: prev: {
      qbittorrent-nox = prev.qbittorrent-nox.overrideAttrs (_old: rec {
        version = "5.1.4";

        src = prev.fetchFromGitHub {
          owner = "qbittorrent";
          repo = "qBittorrent";
          rev = "release-${version}";
          hash = "sha256-9RfKir/e+8Kvln20F+paXqtWzC3KVef2kNGyk1YpSv4=";
        };
      });
    };
  };
}
