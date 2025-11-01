{self, ...}: {
  imports = [
    ./aly
    ./profiles
    ./programs
    self.homeModules.snippets
  ];
}
