{
  config,
  lib,
  ...
}: {
  options.myNixOS.services.morsels = {
    enable = lib.mkEnableOption "morsels atproto pastebin";

    port = lib.mkOption {
      description = "Port to listen on.";
      default = 8484;
      type = lib.types.int;
    };
  };

  config = lib.mkIf config.myNixOS.services.morsels.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.morsels = {
        extraOptions = ["--pull=always"];
        image = "ghcr.io/alyraffauf/morsels";
        ports = ["0.0.0.0:${toString config.myNixOS.services.morsels.port}:8000"];
      };
    };

    myNixOS.programs.podman.enable = true;
  };
}
