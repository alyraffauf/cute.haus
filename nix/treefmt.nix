{
  perSystem.treefmt.config = {
    settings.global.excludes = ["k8s/flux/secrets/*.sops.yaml"];

    programs = {
      alejandra.enable = true;
      deadnix.enable = true;
      prettier.enable = true;
      shellcheck.enable = true;
      shfmt.enable = true;
      statix.enable = true;
      taplo.enable = true;
      terraform.enable = true;
    };
  };
}
