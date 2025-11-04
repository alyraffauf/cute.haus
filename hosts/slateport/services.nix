{config, ...}: {
  services = {
    caddy.virtualHosts = {
      "homebridge.narwhal-snapper.ts.net" = {
        extraConfig = ''
          bind tailscale/homebridge
          encode zstd gzip
          reverse_proxy localhost:${toString config.myNixOS.services.homebridge.port}
        '';
      };
    };
  };
}
