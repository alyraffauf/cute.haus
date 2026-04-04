{
  config,
  lib,
  ...
}: {
  options.myNixOS.services.atbbs = {
    enable = lib.mkEnableOption "atproto bbs";

    port = lib.mkOption {
      description = "Port to listen on.";
      default = 8582;
      type = lib.types.int;
    };
  };

  config = lib.mkIf config.myNixOS.services.atbbs.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.atbbs = {
        extraOptions = ["--pull=always"];
        image = "ghcr.io/alyraffauf/atbbs";
        environment.PUBLIC_URL = "https://atbbs.xyz";
        ports = ["0.0.0.0:${toString config.myNixOS.services.atbbs.port}:8000"];
        volumes = ["/var/lib/atbbs:/data"];
      };
    };

    myNixOS.programs.podman.enable = true;
  };
}
