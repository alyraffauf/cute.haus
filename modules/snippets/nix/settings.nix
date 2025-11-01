{lib, ...}: {
  options = {
    mySnippets.nix.settings = lib.mkOption {
      type = lib.types.attrs;
      description = "Default nix settings shared across machines.";

      default = {
        builders-use-substitutes = true;

        experimental-features = [
          "fetch-closure"
          "flakes"
          "nix-command"
          "recursive-nix"
        ];

        substituters = [
          "https://cache.nixos.org/"
          "https://cutehaus.cachix.org"
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "cutehaus.cachix.org-1:KiifTsseQBitoaHH8rkDUDwzyz9akLeOM+K+e2eK8dA="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        trusted-users = ["aly" "@admin" "@wheel" "nixbuild"];
      };
    };
  };
}
