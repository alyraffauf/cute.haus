{config, ...}: {
  services = {
    caddy = {
      email = "alyraffauf@fastmail.com";

      virtualHosts = {
        "${config.mySnippets.tailnet.networkMap.couchdb.vHost}" = {
          extraConfig = ''
            bind tailscale/couchdb
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.couchdb.hostName}:${toString config.mySnippets.tailnet.networkMap.couchdb.port}
          '';
        };

        "${config.mySnippets.tailnet.networkMap.navidrome.vHost}" = {
          extraConfig = ''
            bind tailscale/navidrome
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.navidrome.hostName}:${toString config.mySnippets.tailnet.networkMap.navidrome.port}
          '';
        };

        "${config.mySnippets.tailnet.networkMap.photoprism.vHost}" = {
          extraConfig = ''
            bind tailscale/photoprism
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.photoprism.hostName}:${toString config.mySnippets.tailnet.networkMap.photoprism.port}
          '';
        };

        "${config.mySnippets.tailnet.networkMap.uptime-kuma.vHost}" = {
          extraConfig = ''
            bind tailscale/uptime-kuma
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.uptime-kuma.hostName}:${toString config.mySnippets.tailnet.networkMap.uptime-kuma.port}
          '';
        };
      };
    };
  };
}
