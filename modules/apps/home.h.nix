{...}: {
  imports = [
    # GUI
    ./gui/firefox.h.nix
    ./gui/wezterm.h.nix
    ./gui/zed.h.nix

    # TUI
    ./tui/btop.h.nix
    ./tui/git.h.nix
    ./tui/helix.h.nix
    ./tui/tealdeer.h.nix
    ./tui/yazi.h.nix
    ./tui/zoxide.h.nix
  ];
}
