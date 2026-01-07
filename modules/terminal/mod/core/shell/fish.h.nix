{pkgs, ...}: {
  home.packages = with pkgs; [
    fish
    fish-lsp
  ];

  programs.fish = {
    enable = true;

    interactiveShellInit =
      /*
      fish
      */
      ''
        set fish_greeting
      '';

    plugins = [
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }

      {
        name = "humantime-fish";
        src = pkgs.fishPlugins.humantime-fish.src;
      }

      {
        name = "colored-man-pages";
        src = pkgs.fishPlugins.colored-man-pages.src;
      }

      {
        name = "fish-you-should-use";
        src = pkgs.fishPlugins.fish-you-should-use.src;
      }
    ];
  };
}
