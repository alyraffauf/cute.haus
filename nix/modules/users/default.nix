{
  config,
  lib,
  pkgs,
  ...
}: {
  config = lib.mkIf (config.myUsers.root.enable or config.myUsers.aly.enable or config.myUsers.dustin.enable) {
    programs.fish.enable = true;

    users = {
      defaultUserShell = pkgs.fish;
      mutableUsers = false;

      users.root.openssh.authorizedKeys.keyFiles = config.myNixOS.sshKeyFiles.aly;
    };
  };
}
