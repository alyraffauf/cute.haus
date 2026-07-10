{self, ...}: {
  flake.modules.nixos.b2-mounts = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.myB2Mounts;

    b2Options = [
      "allow_other"
      "args2env"
      "cache-dir=${cfg.cacheDir}"
      "config=${config.sops.secrets.b2-mount-rclone.path}"
      "dir-cache-time=1h"
      "nodev"
      "nofail"
      "vfs-cache-mode=full"
      "vfs-write-back=10s"
      "x-systemd.after=network-online.target"
      "x-systemd.automount"
    ];

    b2ProfileOptions = {
      audio = [
        "buffer-size=128M"
        "vfs-cache-max-age=168h"
        "vfs-cache-max-size=${cfg.audioCacheSize}"
        "vfs-read-ahead=${cfg.audioReadAhead}"
      ];

      video = [
        "buffer-size=512M"
        "vfs-cache-max-age=336h"
        "vfs-cache-max-size=${cfg.videoCacheSize}"
        "vfs-read-ahead=${cfg.videoReadAhead}"
      ];
    };

    mkB2Mount = name: remote: profile: {
      "/mnt/Backblaze/${name}" = {
        device = "b2:${remote}";
        fsType = "rclone";
        options = b2Options ++ b2ProfileOptions.${profile};
      };
    };

    allShares = {
      Anime = mkB2Mount "Anime" "aly-anime" "video";
      Audiobooks = mkB2Mount "Audiobooks" "aly-audiobooks" "audio";
      Movies = mkB2Mount "Movies" "aly-movies" "video";
      Music = mkB2Mount "Music" "aly-music" "audio";
      Shows = mkB2Mount "Shows" "aly-shows" "video";
    };
  in {
    options.myB2Mounts = {
      cacheDir = lib.mkOption {
        description = "Directory for rclone VFS cache.";
        example = "/mnt/Data/.rclone-cache";
        type = lib.types.str;
      };

      audioCacheSize = lib.mkOption {
        default = "15G";
        type = lib.types.str;
      };
      videoCacheSize = lib.mkOption {
        default = "50G";
        type = lib.types.str;
      };
      audioReadAhead = lib.mkOption {
        default = "1G";
        type = lib.types.str;
      };
      videoReadAhead = lib.mkOption {
        default = "3G";
        type = lib.types.str;
      };

      shares = lib.mkOption {
        description = "Which B2 shares to mount.";
        default = ["Anime" "Audiobooks" "Movies" "Music" "Shows"];
        type = lib.types.listOf (lib.types.enum ["Anime" "Audiobooks" "Movies" "Music" "Shows"]);
      };
    };

    config = {
      sops.secrets.b2-mount-rclone = {
        sopsFile = "${self}/secrets/b2.yaml";
        key = "rclone_config";
      };

      environment.systemPackages = [pkgs.rclone];

      fileSystems = builtins.foldl' (a: b: a // b) {} (builtins.attrValues (builtins.intersectAttrs (builtins.listToAttrs (map (s: {
          name = s;
          value = null;
        })
        cfg.shares))
      allShares));

      # Drop-in overrides: remove the StartLimitBurst cap so automount
      # retries indefinitely after a transient network failure.
      # These merge into the fileSystems-generated mount units without
      # redefining them.
      systemd.units =
        builtins.foldl' (a: b: a // b) {}
        (map (share: {
          "mnt-Backblaze-${share}.mount" = {
            overrideStrategy = "asDropin";
            unitConfig = {
              StartLimitIntervalSec = "0";
            };
          };
        }) cfg.shares);

      systemd.services.b2-mount-health = let
        # Bash will iterate over cfg.shares — names are enum-constrained
        # so no spaces or special characters are possible.
        healthScript = pkgs.writeShellScript "b2-mount-health" ''
          for share in ${toString cfg.shares}; do
            path="/mnt/Backblaze/$share"
            unit="mnt-Backblaze-$share"
            if ! mountpoint -q "$path"; then
              # Not mounted at all — reset and retry
              systemctl reset-failed "$unit.mount" "$unit.automount" 2>/dev/null || true
              systemctl start "$unit.mount" || true
            elif ! timeout 10 ls "$path" >/dev/null 2>&1; then
              # Mounted but stale (rclone process died, kernel has ENOTCONN)
              # Lazy-unmount to clear the dead session, then restart
              umount -l "$path" 2>/dev/null || true
              systemctl reset-failed "$unit.mount" "$unit.automount" 2>/dev/null || true
              systemctl start "$unit.mount" || true
            fi
          done
        '';
      in {
        description = "B2 FUSE mount health check — restarts failed or stale mounts";
        after = ["network-online.target"];
        wants = ["network-online.target"];
        serviceConfig.Type = "oneshot";
        serviceConfig.ExecStart = "${healthScript}";
      };

      systemd.timers.b2-mount-health = {
        description = "Periodic B2 mount health check";
        timerConfig = {
          OnCalendar = "*:0/5";
          Persistent = true;
        };
        wantedBy = ["timers.target"];
      };
    };
  };
}
