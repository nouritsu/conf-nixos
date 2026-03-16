{
  flake.nixosModules.app-brave = {...}: {
    my.hmModules = ["app-brave"];

    environment.etc."brave/policies/managed/default.json".text = builtins.toJSON {
      ExtensionInstallForcelist = [
        "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx" # sponsor block
        "eimadpbcbfnmbkopoojfekhnkhdbieeh;https://clients2.google.com/service/update2/crx" # dark reader
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx" # bit warden
        "lnjaiaapbakfhlbjenjkhffcdpoompki;https://clients2.google.com/service/update2/crx" # catppuccin icons
      ];

      # disable brave bloat
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = 1;
      BraveAIChatEnabled = false;

      # misc
      PasswordManagerEnabled = false;
      BookmarkBarEnabled = true;
    };
  };

  flake.homeModules.app-brave = {
    pkgs,
    lib,
    ...
  }: let
    patchScript = pkgs.writers.writePython3 "brave-site-search-patch" {
      flakeIgnore = ["E501"];
    } (builtins.readFile ./brave-search-patch.py);
  in {
    programs.brave = {
      enable = true;
      commandLineArgs = [
        "--enable-features=WebBluetooth"
      ];
    };

    home.activation.braveSiteSearch = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${patchScript}
    '';

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, W, exec, brave"
    ];
    wayland.windowManager.hyprland.settings.windowrule = [
      "opacity 1.0 override 1.0 override, match:class brave-browser"
    ];
  };
}
