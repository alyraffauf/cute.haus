{
  config,
  lib,
  pkgs,
  self,
  ...
}: {
  options.myNixOS.profiles.base = {
    enable = lib.mkEnableOption "base system configuration";

    flakeUrl = lib.mkOption {
      type = lib.types.str;
      default = "github:alyraffauf/cute.haus";
      description = "Default flake URL for the system";
    };
  };

  config = lib.mkIf config.myNixOS.profiles.base.enable {
    boot.kernel.sysctl = {
      # Improved file monitoring
      "fs.file-max" = lib.mkDefault 2097152;
      "fs.inotify.max_user_instances" = lib.mkOverride 100 8192;
      "fs.inotify.max_user_watches" = lib.mkOverride 100 524288;
    };

    documentation = {
      enable = false;
      nixos.enable = false;
    };

    environment = {
      etc."nixos".source = self;

      systemPackages = with pkgs; [
        (inxi.override {withRecommends = true;})
        (lib.hiPrio uutils-coreutils-noprefix)
        git
        helix
        htop
        lm_sensors
        wget
      ];

      variables = {
        FLAKE = config.myNixOS.profiles.base.flakeUrl;
        NH_FLAKE = config.myNixOS.profiles.base.flakeUrl;
      };
    };

    programs = {
      dconf.enable = true; # Needed for home-manager
      nh.enable = true;
      ssh.knownHosts = config.mySnippets.ssh.knownHosts;
    };

    networking.networkmanager.enable = true;
    security.sudo-rs.enable = true;

    services = {
      bpftune.enable = true;

      cachefilesd = {
        enable = true;

        extraConfig = ''
          brun 20%
          bcull 10%
          bstop 5%
        '';
      };

      journald = {
        storage = "volatile";
        extraConfig = "SystemMaxUse=32M\nRuntimeMaxUse=32M";
      };

      openssh = {
        enable = true;
        openFirewall = true;
        settings.PasswordAuthentication = false;
      };

      timesyncd.enable = true;
      vscode-server.enable = true;
    };

    system.configurationRevision = self.rev or self.dirtyRev or null;

    systemd = {
      coredump.enable = false;
      enableEmergencyMode = false;

      oomd = {
        enable = true;
        enableRootSlice = true;
        enableSystemSlice = true;
        enableUserSlices = true;
      };
    };

    zramSwap = {
      enable = lib.mkDefault true;
      algorithm = lib.mkDefault "zstd";
      priority = lib.mkDefault 100;
    };

    myNixOS = {
      programs.njust.enable = true;
      services.fail2ban.enable = true;
    };
  };
}
