{
  pkgs,
  self,
  ...
}: {
  imports = [
    self.homeModules.default
    self.inputs.agenix.homeManagerModules.default
    self.inputs.safari.homeModules.default
  ];

  age.secrets.rclone-b2.file = "${self.inputs.secrets}/rclone/b2.age";

  home = {
    homeDirectory = "/home/aly";

    packages = with pkgs; [
      curl
      rclone
      restic
    ];

    stateVersion = "25.11";
    username = "aly";
  };

  programs.helix.defaultEditor = true;
  safari.enable = true;

  myHome.aly.programs = {
    git.enable = true;
    awscli.enable = true;
    ssh.enable = true;
  };
}
