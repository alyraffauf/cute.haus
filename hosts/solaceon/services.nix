{config, ...}: {
  services = {
    bluesky-pds = {
      enable = true;
      environmentFiles = [config.age.secrets.pds.path];
      goat.enable = true;
      pdsadmin.enable = true;
      settings.PDS_HOSTNAME = config.mySnippets.cute-haus.networkMap.aly-social.vHost;
    };
  };

  systemd.services = {
    bluesky-pds.serviceConfig = {
      MemoryHigh = "384M";
      MemoryMax = "512M";
    };

    forgejo.serviceConfig = {
      MemoryMax = "512M";
    };

    fail2ban.serviceConfig = {
      MemoryHigh = "192M";
      MemoryMax = "256M";
    };
  };
}
