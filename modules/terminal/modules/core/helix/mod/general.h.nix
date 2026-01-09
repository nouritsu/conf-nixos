{lib, pkgs, ...}: let
  fish = lib.getExe pkgs.fish;
in {
  programs.helix.settings.editor = {
    line-number = "relative";
    cursor-shape.insert = "bar";
    shell = [
      fish
      "-c"
    ];

    indent-guides = {
      render = true;
      character = "┆";
      skip-levels = 1;
    };

    bufferline = "multiple";
    cursorline = true;
    clipboard-provider = "wayland";
  };
}
