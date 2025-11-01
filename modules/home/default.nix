{self, ...}: {
  imports = [
    ./aly
    ./profiles
    ./programs
    self.inputs.snippets.homeModules.snippets
  ];
}
