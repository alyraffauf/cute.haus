{config, ...}: {
  services.restic.backups = {
    dizquetv = {
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
      paths = ["/mnt/Data/dizquetv"];
      repository = "rclone:b2:aly-backups/${config.networking.hostName}/dizquetv";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "3h";
      };
    };
  };
}
