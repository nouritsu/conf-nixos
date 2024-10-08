{ pkgs, users, ... }: {
  users.defaultUserShell = pkgs.zsh;

  # Shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;

    shellAliases = {
      # ls Aliases
      ls = "lsd";
      ll = "ls -l";
      la = "ls -la";
      l = "ls -ltra";

      # Core Util Aliases
      c = "clear";
      cat = "bat";
      du = "dust";
      grep = "rg";
      h = "history";
      top = "btop";
      btop = "btop --utf-force";

      # Miscellaneous Aliases
      neofetch = "nerdfetch";
      pomo = "pomodoro";
      speedtest = "speedtest-rs";
      wiki = "wiki-tui";
      youtubedl = "yt-dlp";

      # Nix Aliases
      rebs = "echo WIP";
	  rebb = "echo WIP";
    };

    ohMyZsh = {
      enable = true;
      theme = "cloud";
      plugins = [ "adb" "aliases" "ripgrep"];
    };

  };
}
