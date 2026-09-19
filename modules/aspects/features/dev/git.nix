{
  den.aspects.aneesh.homeManager = {pkgs, ...}: {
    programs.git = {
      enable = true;
      settings.user = {
        name = "Aneesh Bhave";
        email = "aneesh1701@gmail.com";
      };
    };
    programs.lazygit.enable = true;
    programs.fish.plugins = [
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
    programs.delta.enableGitIntegration = true;

    programs.gh = {
      enable = true;
      extensions = [
        pkgs.gh-markdown-preview
        pkgs.gh-poi
        pkgs.gh-f
      ];
    };
    programs.gh-dash.enable = true;

    programs.jujutsu = {
      enable = true;
      settings = {
        user = "Aneesh Bhave";
        email = "aneesh1701@gmail.com";
      };
    };
    programs.jjui.enable = true;
    programs.fish.shellAliases.lazyjj = "jjui";
    programs.delta.enableJujutsuIntegration = true;

    programs.delta.enable = true;
  };
}
