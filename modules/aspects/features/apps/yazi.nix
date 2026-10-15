{
  den.aspects.yazi.nixos = {self', ...}: {
    environment.systemPackages = [
      self'.packages.yazi
    ];

    nix.settings = {
      extra-substituters = ["https://yazi.cachix.org"];
      trusted-public-keys = ["yazi.cachix.org-1:Dcdz63NZKfvUCbDGngQDAZq6kOroIrFoyO064uvLh8k="];
    };

    programs.fish.shellAliases.fm = "yazi";

    # cd-on-quit wrapper
    programs.fish.interactiveShellInit = ''
      function yazi_wrapper
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
          builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      end
    '';
  };
}
