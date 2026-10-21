{
  den.aspects.nix.abbrs.nixos = {
    programs.fish.shellAliases.conf = "$EDITOR $NH_FLAKE";
    programs.fish.shellAbbrs = {
      nhrb = "nh os boot";
      nhrs = "nh os switch";
      nhrt = "nh os test";
      nhca = "nh clean all";
      nhs = "nh search";

      nd = "nix develop";
      nb = "nix build";
      nfu = "nix flake update";
      nfs = "nix flake show";
    };

    programs.fish.interactiveShellInit = ''
      abbr -a nr --set-cursor 'nix run nixpkgs#%'
    '';
  };
}
