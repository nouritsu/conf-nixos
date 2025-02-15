{...}: {
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor.cursor-shape = {
        normal = "block";
        insert = "line";
        visual = "block";
      };
    };

    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = "${pkgs.alejandra}";
      }
    ];
  };
}
