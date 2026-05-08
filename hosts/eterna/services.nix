{config, ...}: {
  networking = {
    firewall.allowedTCPPorts = [80 443 2379 2380 3000 6443 61208];
    firewall.allowedUDPPorts = [8472];
  };

  myNixOS.services = {
    atbbs.enable = true;
  };

  services = {
    audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      openFirewall = true;
      port = 13378;
    };

    caddy = {
      email = "alyraffauf@fastmail.com";
      virtualHosts = {
        "${config.mySnippets.tailnet.networkMap.grafana.vHost}" = {
          extraConfig = ''
            bind tailscale/grafana
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.grafana.hostName}:${toString config.mySnippets.tailnet.networkMap.grafana.port}
          '';
        };

        "${config.mySnippets.tailnet.networkMap.loki.vHost}" = {
          extraConfig = ''
            bind tailscale/loki
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.loki.hostName}:${toString config.mySnippets.tailnet.networkMap.loki.port}
          '';
        };

        "${config.mySnippets.tailnet.networkMap.prometheus.vHost}" = {
          extraConfig = ''
            bind tailscale/prometheus
            encode zstd gzip
            reverse_proxy ${config.mySnippets.tailnet.networkMap.prometheus.hostName}:${toString config.mySnippets.tailnet.networkMap.prometheus.port}
          '';
        };
      };
    };

    karakeep = {
      enable = false;

      extraEnvironment = rec {
        DISABLE_NEW_RELEASE_CHECK = "true";
        DISABLE_SIGNUPS = "true";
        INFERENCE_CONTEXT_LENGTH = "128000";
        INFERENCE_EMBEDDING_MODEL = "nomic-embed-text";
        INFERENCE_ENABLE_AUTO_SUMMARIZATION = "true";
        INFERENCE_IMAGE_MODEL = "gemma3:4b";
        INFERENCE_JOB_TIMEOUT_SEC = "600";
        INFERENCE_LANG = "english";
        INFERENCE_TEXT_MODEL = INFERENCE_IMAGE_MODEL;
        NEXTAUTH_URL = "https://${config.mySnippets.cute-haus.networkMap.karakeep.vHost}";
        OLLAMA_BASE_URL = "https://ollama.${config.mySnippets.tailnet.name}";
        OLLAMA_KEEP_ALIVE = "5m";
        PORT = "7020";
      };
    };

    meilisearch.settings.experimental_dumpless_upgrade = true;
  };
}
