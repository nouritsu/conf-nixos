{inputs, ...}: {
  den.aspects.catppuccin.nixos = {
    config,
    pkgs,
    ...
  }: let
    catppuccin-mocha-dark-cursors = pkgs.stdenvNoCC.mkDerivation {
      pname = "catppuccin-mocha-dark-cursors";
      version = "2.0.0";
      src = pkgs.fetchzip {
        url = "https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-dark-cursors.zip";
        hash = "sha256-R11v0XU5IPeIJ7Sy4xSomcgWFvGWsDTeejeJq/GPRmc=";
        stripRoot = false;
      };
      installPhase = ''
        mkdir -p $out/share/icons
        cp -r catppuccin-mocha-dark-cursors $out/share/icons/
      '';
      meta.description = "Catppuccin Mocha Dark cursor theme (prebuilt)";
    };
  in {
    imports = [inputs.catppuccin.nixosModules.catppuccin];

    # The assets DMS chooses between. It picks the icon theme (Papirus-Dark)
    # and the cursor, and hands both to GTK, Qt, niri and the portal.
    environment.systemPackages = [
      (pkgs.catppuccin-papirus-folders.override {
        inherit (config.catppuccin) flavor accent;
      })
      catppuccin-mocha-dark-cursors
    ];

    catppuccin = {
      enable = true;
      # Enrol every port by default. Upstream is splitting the two knobs:
      # `enable` becomes a global kill switch, `autoEnable` does the enrolling.
      # Setting both keeps today's behaviour once that lands.
      autoEnable = true;
      cache.enable = true;
      flavor = "mocha";
      accent = "mauve";

      gtk.icon.enable = true;
      grub.enable = true;
    };
  };

  den.aspects.catppuccin.homeManager = {
    imports = [inputs.catppuccin.homeModules.catppuccin];

    catppuccin = {
      enable = true;
      autoEnable = true;
      cache.enable = true;
      flavor = "mocha";
      accent = "mauve";

      bat.enable = true;
      # The browser here is Floorp (packages/floorp/floorp.nix), which carries
      # Catppuccin Mocha/Mauve as a force-installed add-on. There is no
      # `programs.firefox` profile for this port to attach to.
      firefox.enable = false;
      fish.enable = true;
      fzf.enable = true;
      hyprlock.enable = false;
      lsd.enable = true;
      wezterm.enable = true;
      zed = {
        enable = true;
        icons.enable = true;
      };
    };
  };
}
