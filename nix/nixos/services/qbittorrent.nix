{
  flake.modules.nixos.qbittorrent.services.qbittorrent = {
    enable = true;
    profileDir = "/var/lib/qbittorrent";
  };

  flake.modules.nixos.backups = {
    config,
    lib,
    pkgs,
    ...
  }: let
    stop = service: "${pkgs.systemd}/bin/systemctl stop ${service}";
    start = service: "${pkgs.systemd}/bin/systemctl start ${service}";
  in {
    config.myBackups.jobs.qbittorrent = lib.mkIf config.services.qbittorrent.enable {
      backupCleanupCommand = start "qbittorrent";
      backupPrepareCommand = stop "qbittorrent";
      paths = [config.services.qbittorrent.profileDir];
    };
  };
}
