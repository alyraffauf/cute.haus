{
  config,
  lib,
  ...
}: {
  config = lib.mkIf config.myUsers.aly.enable {
    users.users.aly = {
      description = "Aly Raffauf";
      extraGroups = config.myUsers.defaultGroups;
      hashedPassword = config.myUsers.aly.password;
      isNormalUser = true;

      openssh.authorizedKeys.keyFiles = config.myNixOS.sshKeyFiles.aly;

      uid = 1000;
    };
  };
}
