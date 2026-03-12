{config, ...}: {
  services.restic.backups = {
    syncthing-sync =
      config.mySnippets.restic
      // {
        paths = ["/home/aly/sync"];
        repository = "rclone:b2:aly-backups/syncthing/sync";
      };

    syncthing-roms =
      config.mySnippets.restic
      // {
        paths = [config.myNixOS.services.syncthing.romsPath];
        repository = "rclone:b2:aly-backups/syncthing/roms";
      };
  };
}
