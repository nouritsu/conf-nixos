{inputs, ...}: {
  imports = [inputs.stylix.nixosModules.stylix];

  stylix = {
    enable = true;
    targets = {
      grub.enable = false;
      gtk.enable = false;
    };
  };
}
