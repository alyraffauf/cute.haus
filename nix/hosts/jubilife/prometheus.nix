{
  config,
  self,
  ...
}: {
  sops.secrets = {
    bazarrApiKey = {
      sopsFile = "${self}/secrets/arr.yaml";
      key = "bazarr_api_key";
    };
    lidarrApiKey = {
      sopsFile = "${self}/secrets/arr.yaml";
      key = "lidarr_api_key";
    };
    prowlarrApiKey = {
      sopsFile = "${self}/secrets/arr.yaml";
      key = "prowlarr_api_key";
    };
    radarrApiKey = {
      sopsFile = "${self}/secrets/arr.yaml";
      key = "radarr_api_key";
    };
    sonarrApiKey = {
      sopsFile = "${self}/secrets/arr.yaml";
      key = "sonarr_api_key";
    };
  };

  services.prometheus.exporters = {
    exportarr-bazarr = {
      enable = true;
      apiKeyFile = config.sops.secrets.bazarrApiKey.path;
      port = 9708;
      url = "https://bazarr.narwhal-snapper.ts.net";
    };

    exportarr-lidarr = {
      enable = true;
      apiKeyFile = config.sops.secrets.lidarrApiKey.path;
      port = 9709;
      url = "https://lidarr.narwhal-snapper.ts.net";
    };

    exportarr-prowlarr = {
      enable = true;
      apiKeyFile = config.sops.secrets.prowlarrApiKey.path;
      port = 9710;
      url = "https://prowlarr.narwhal-snapper.ts.net";
    };

    exportarr-radarr = {
      enable = true;
      apiKeyFile = config.sops.secrets.radarrApiKey.path;
      port = 9711;
      url = "https://radarr.narwhal-snapper.ts.net";
    };

    exportarr-sonarr = {
      enable = true;
      apiKeyFile = config.sops.secrets.sonarrApiKey.path;
      port = 9712;
      url = "https://sonarr.narwhal-snapper.ts.net";
    };

    smartctl.enable = true;
  };
}
