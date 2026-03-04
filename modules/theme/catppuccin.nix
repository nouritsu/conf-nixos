{inputs, ...}: {
  imports = [inputs.catppuccin.nixosModules.catppuccin];

  catppuccin = {
    enable = true;
    cache.enable = true;
    flavor = "mocha";
    accent = "mauve";

    gtk.icon.enable = true;
  };
}
