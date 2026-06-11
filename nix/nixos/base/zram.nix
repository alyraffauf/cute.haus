{
  flake.modules.nixos.base = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 100;
    };
  };
}
