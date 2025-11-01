{self, ...}: {
  imports = [
    ./aly
    ./profiles
    ./programs
    ./services
    self.homeModules.snippets
    self.inputs.zen-browser.homeModules.beta
  ];
}
