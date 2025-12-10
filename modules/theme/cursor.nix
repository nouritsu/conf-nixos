{pkgs, ...}: {
  stylix = {
    cursor = {
      name = "Capitaine Cursors (Gruvbox)";
      package = pkgs.capitaine-cursors-themed;
      size = 15;
    };
  };
}
