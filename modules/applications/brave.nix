{
  flake.nixosModules.app-brave = {...}: {
    my.hmModules = ["app-brave"];

    environment.etc."brave/policies/managed/default.json".text = builtins.toJSON {
      ExtensionInstallForcelist = map (id: "${id};https://clients2.google.com/service/update2/crx") [
        "mnjggcdmjocbbbhaepdhchncahnbgone" # sponsor block
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
        "lnjaiaapbakfhlbjenjkhffcdpoompki" # catppuccin icons
        "ghmbeldphafepmbegfdlkpapadhbakde" # proton pass
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
      flakeIgnore = ["E501"]; # violation caused by long URLs
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
  };
}
