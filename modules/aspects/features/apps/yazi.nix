{
  den.aspects.yazi.nixos = {self', ...}: {
    environment.systemPackages = [
      self'.packages.yazi
    ];

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
