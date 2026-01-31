{
  config,
  lib,
  ...
}: {
  options.myNixOS.services.watsup = {
    enable = lib.mkEnableOption "watsup homelab dashboard";

    port = lib.mkOption {
      description = "Port to listen on.";
      default = 8383;
      type = lib.types.int;
    };
  };

  config = lib.mkIf config.myNixOS.services.watsup.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.watsup = {
        extraOptions = ["--pull=always"];
        image = "ghcr.io/alyraffauf/watsup";
        ports = ["0.0.0.0:${toString config.myNixOS.services.watsup.port}:3000"];
      };
    };

    myNixOS.programs.podman.enable = true;
  };
}
