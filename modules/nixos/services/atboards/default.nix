{
  config,
  lib,
  ...
}: {
  options.myNixOS.services.atboards = {
    enable = lib.mkEnableOption "atboards atproto bbs";

    port = lib.mkOption {
      description = "Port to listen on.";
      default = 8582;
      type = lib.types.int;
    };
  };

  config = lib.mkIf config.myNixOS.services.atboards.enable {
    virtualisation.oci-containers = {
      backend = "podman";

      containers.atboards = {
        extraOptions = ["--pull=always"];
        image = "ghcr.io/alyraffauf/atboards";
        environment.PUBLIC_URL = "https://atboards.xyz";
        ports = ["0.0.0.0:${toString config.myNixOS.services.atboards.port}:8000"];
        volumes = ["/var/lib/atboards:/data"];
      };
    };

    myNixOS.programs.podman.enable = true;
  };
}
