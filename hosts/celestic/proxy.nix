{
  config,
  pkgs,
  self,
  ...
}: {
  security.acme = {
    acceptTerms = true;
    defaults.email = "alyraffauf@fastmail.com";
  };

  services = {
    caddy = {
      email = "alyraffauf@fastmail.com";

      virtualHosts = {
        "morsels.blue" = {
          extraConfig = ''
            encode gzip zstd
            reverse_proxy ${config.mySnippets.cute-haus.networkMap.morsels.hostName}:${toString config.mySnippets.cute-haus.networkMap.morsels.port}
          '';

          serverAliases = ["www.morsels.blue"];
        };

        "aly.codes" = {
          extraConfig = ''
            encode gzip zstd
            reverse_proxy ${config.mySnippets.cute-haus.networkMap.aly-codes.hostName}:${toString config.mySnippets.cute-haus.networkMap.aly-codes.port}
          '';

          serverAliases = ["www.aly.codes"];
        };

        "aly.social" = {
          extraConfig = ''
            encode zstd gzip

            # https://gist.github.com/mary-ext/6e27b24a83838202908808ad528b3318
            handle /xrpc/app.bsky.unspecced.getAgeAssuranceState {
              header content-type "application/json"
              header access-control-allow-headers "authorization,dpop,atproto-accept-labelers,atproto-proxy"
              header access-control-allow-origin "*"
              respond `{"lastInitiatedAt":"2025-07-14T14:22:43.912Z","status":"assured"}` 200
            }

            reverse_proxy ${config.mySnippets.cute-haus.networkMap.aly-social.hostName}:${toString config.mySnippets.cute-haus.networkMap.aly-social.port}
          '';
        };

        "${config.mySnippets.cute-haus.networkMap.forgejo.vHost}" = {
          extraConfig = ''
            encode zstd gzip

            @uploads method POST PUT
            handle @uploads {
              request_body { max_size 2GB }
            }

            reverse_proxy ${config.mySnippets.cute-haus.networkMap.forgejo.hostName}:${toString config.mySnippets.cute-haus.networkMap.forgejo.port} {
              header_up X-Real-Ip {remote_host}
            }
          '';
        };

        "self2025.aly.codes" = {
          extraConfig = let
            site = self.inputs.self2025.packages.${pkgs.stdenv.hostPlatform.system}.default;
          in ''
            encode zstd gzip
            file_server
            root * ${site}
          '';
        };

        "status.aly.codes" = {
          extraConfig = ''
            encode gzip zstd
            reverse_proxy ${config.mySnippets.cute-haus.networkMap.uptime-kuma.hostName}:${toString config.mySnippets.cute-haus.networkMap.uptime-kuma.port}
          '';
        };

        "status.aly.social" = {
          extraConfig = ''
            encode gzip zstd
            reverse_proxy ${config.mySnippets.cute-haus.networkMap.uptime-kuma.hostName}:${toString config.mySnippets.cute-haus.networkMap.uptime-kuma.port}
          '';
        };
      };
    };
  };
}
