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
      nfc = "nix flake check";
      nfl = "nix flake lock";
      nfm = "nix flake metadata";
      nfmt = "nix fmt";
      nrepl = "nix repl";
      nlog = "nix log";
      nwhy = "nix why-depends";
    };

    programs.fish.interactiveShellInit = ''
      abbr -a npr --set-cursor 'nix run nixpkgs#%'
      abbr -a nfr --set-cursor 'nix run .#%'
      abbr -a nfb --set-cursor 'nix build .#%'
      abbr -a nps --set-cursor 'nix shell nixpkgs#%'
      abbr -a nfe --set-cursor 'nix eval .#%'
    '';
  };
}
