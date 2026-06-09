{config, ...}: let
  restic = {
    extraBackupArgs = [
      "--cleanup-cache"
      "--compression max"
      "--no-scan"
    ];
    inhibitsSleep = true;
    initialize = true;
    passwordFile = config.sops.secrets.restic-passwd.path;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 3"
    ];
    rcloneConfigFile = config.sops.secrets.rclone-b2.path;
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "3h";
    };
  };
in {
  services.restic.backups = {
    syncthing-sync =
      restic
      // {
        paths = ["/home/aly/sync"];
        repository = "rclone:b2:aly-backups/syncthing/sync";
      };

    syncthing-roms =
      restic
      // {
        paths = [config.myNixOS.services.syncthing.romsPath];
        repository = "rclone:b2:aly-backups/syncthing/roms";
      };
  };
}
