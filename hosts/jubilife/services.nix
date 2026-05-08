{config, ...}: let
  dataDirectory = "/mnt/Data";
in {
  # 6881: bittorrent. 20048: NFSv3 mountd, pinned below — needed because
  # k3s pod traffic (jellyfin's nfs-mount sidecar) doesn't get the
  # tailscale0/lo blanket-accept, only nfsd's 2049 happens to work
  # without an explicit hole. Sidecar uses `nolock`, so no statd/lockd.
  networking.firewall.allowedTCPPorts = [6881 20048];
  networking.firewall.allowedUDPPorts = [20048];

  services = {
    caddy.virtualHosts = {
      "${config.mySnippets.tailnet.networkMap.bazarr.vHost}" = {
        extraConfig = ''
          bind tailscale/bazarr
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.bazarr.hostName}:${toString config.mySnippets.tailnet.networkMap.bazarr.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.lidarr.vHost}" = {
        extraConfig = ''
          bind tailscale/lidarr
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.lidarr.hostName}:${toString config.mySnippets.tailnet.networkMap.lidarr.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.ollama.vHost}" = {
        extraConfig = ''
          bind tailscale/ollama
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.ollama.hostName}:${toString config.mySnippets.tailnet.networkMap.ollama.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.prowlarr.vHost}" = {
        extraConfig = ''
          bind tailscale/prowlarr
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.prowlarr.hostName}:${toString config.mySnippets.tailnet.networkMap.prowlarr.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.qbittorrent.vHost}" = {
        extraConfig = ''
          bind tailscale/qbittorrent
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.qbittorrent.hostName}:${toString config.mySnippets.tailnet.networkMap.qbittorrent.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.radarr.vHost}" = {
        extraConfig = ''
          bind tailscale/radarr
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.radarr.hostName}:${toString config.mySnippets.tailnet.networkMap.radarr.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.sonarr.vHost}" = {
        extraConfig = ''
          bind tailscale/sonarr
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.sonarr.hostName}:${toString config.mySnippets.tailnet.networkMap.sonarr.port}
        '';
      };

      "${config.mySnippets.tailnet.networkMap.tautulli.vHost}" = {
        extraConfig = ''
          bind tailscale/tautulli
          encode zstd gzip
          reverse_proxy ${config.mySnippets.tailnet.networkMap.tautulli.hostName}:${toString config.mySnippets.tailnet.networkMap.tautulli.port}
        '';
      };
    };

    immich = {
      enable = true;
      host = "0.0.0.0";
      mediaLocation = "${dataDirectory}/immich";
      openFirewall = true;
      inherit (config.mySnippets.cute-haus.networkMap.immich) port;
    };

    nfs.server = {
      enable = true;

      # Pin mountd's port so we can open it in the firewall. Without
      # this it'd be assigned a random port per boot.
      mountdPort = 20048;

      # 100.64.0.0/10 is the tailnet. 10.42.0.0/16 is the k3s pod CIDR
      # (jellyfin's nfs-mount sidecar mounts from inside a pod on
      # jubilife, source IP arrives as the pod IP, not the host).
      exports = ''
        /mnt/Data 100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash,fsid=0) 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash,fsid=0)
        /mnt/Media 100.64.0.0/10(rw,sync,no_subtree_check,no_root_squash,fsid=1) 10.42.0.0/16(rw,sync,no_subtree_check,no_root_squash,fsid=1)
      '';
    };

    ollama = {
      enable = true;
      host = "0.0.0.0";

      loadModels = [
        "gemma3:12b"
        "gemma3:4b"
        "nomic-embed-text"
      ];

      openFirewall = true;
    };

    ombi = {
      inherit (config.mySnippets.cute-haus.networkMap.ombi) port;
      enable = true;
      dataDir = "/mnt/Data/ombi";
      openFirewall = true;
    };

    photoprism = {
      enable = true;
      originalsPath = "/mnt/Media/Photos/";
      address = "0.0.0.0";
      passwordFile = config.age.secrets.photoprismAdminPass.path;

      settings = {
        PHOTOPRISM_SITE_URL = "https://photoprism.narwhal-snapper.ts.net";
        PHOTOPRISM_UPLOAD_NSFW = "true";
      };
    };

    samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          security = "user";
          "map to guest" = "Bad User";

          # Protocol tuning
          "server min protocol" = "SMB3";
          "server max protocol" = "SMB3_11";

          # Performance options
          "socket options" = "TCP_NODELAY IPTOS_LOWDELAY SO_RCVBUF=262144 SO_SNDBUF=262144";
          "use sendfile" = "no"; # Plex compatibility
          "aio read size" = "1";
          "aio write size" = "1";
          "min receivefile size" = "131072"; # Bump slightly from 16K to 128K
          "max xmit" = "65535"; # Samba's max recommended for best throughput

          # Locking & latency
          "strict locking" = "no";
          "oplocks" = "yes";
          "level2 oplocks" = "yes";
        };

        Data = {
          "create mask" = "0755";
          "directory mask" = "0755";
          "force group" = "users";
          "force user" = "aly";
          "guest ok" = "yes";
          "read only" = "no";
          browseable = "yes";
          comment = "Data @ ${config.networking.hostName}";
          path = dataDirectory;
        };

        Media = {
          "create mask" = "0755";
          "directory mask" = "0755";
          "force group" = "users";
          "force user" = "aly";
          "guest ok" = "yes";
          "read only" = "no";
          browseable = "yes";
          comment = "Media @ ${config.networking.hostName}";
          path = "/mnt/Media";
        };
      };
    };

    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };

    smartd.enable = true;

    snapper.configs.media = {
      ALLOW_GROUPS = ["users"];
      FSTYPE = "btrfs";
      SUBVOLUME = "/mnt/Media";
      TIMELINE_CLEANUP = true;
      TIMELINE_CREATE = true;
    };

    tuned = {
      enable = true;
      settings.dynamic_tuning = true;
    };

    xserver.xkb.options = "ctrl:nocaps";
  };
}
