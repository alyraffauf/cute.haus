{
  config,
  modulesPath,
  self,
  ...
}: {
  imports = [
    # ./anubis.nix
    ./proxy.nix
    ./secrets.nix
    "${modulesPath}/profiles/qemu-guest.nix"
    self.diskoConfigurations.lvm-ext4
    self.nixosModules.locale-en-us
  ];

  boot = {
    initrd.availableKernelModules = [
      "ahci"
      "sd_mod"
      "sr_mod"
      "virtio_pci"
      "virtio_scsi"
      "xhci_pci"
    ];

    loader.grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
    };
  };

  networking = {
    firewall.allowedTCPPorts = [80 443];
    hostName = "celestic";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  programs.ssh.knownHosts = config.mySnippets.ssh.knownHosts;
  system.stateVersion = "25.11";
  time.timeZone = "America/New_York";
  myDisko.installDrive = "/dev/sda";

  myNixOS = {
    base.enable = true;

    profiles = {
      autoUpgrade.enable = true;
      backups.enable = true;
      vps.enable = true;

      swap = {
        enable = true;
        size = 2048;
      };
    };

    programs = {
      nix.enable = true;
      podman.enable = true;
    };

    services = {
      caddy.enable = true;
      prometheusNode.enable = true;
      promtail.enable = true;
      tailscale.enable = true;
    };
  };

  myUsers.root.enable = true;
}
