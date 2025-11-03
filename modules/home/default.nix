{self, ...}: {
  imports = [
    ./aly
    self.inputs.snippets.homeModules.snippets
  ];
}
