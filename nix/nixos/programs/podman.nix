{
  flake.modules.nixos.podman = {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      dockerCompat = true;
    };
  };
}
