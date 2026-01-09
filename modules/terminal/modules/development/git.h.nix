{
  pkgs,
  osConfig,
  ...
}: {
  home.packages = with pkgs; [
    git
    gh
  ];

  programs = {
    git = {
      enable = true;
      settings.user = {
        user = osConfig.my.user.name;
        email = osConfig.my.user.email;
      };
    };
    delta.enable = true;
    gh.enable = true;

    fish.plugins = [
      {
        name = "forgit";
        src = pkgs.fishPlugins.forgit.src;
      }
    ];
  };
}
