{pkgs, ...}: {
  imports = [
    ./internet.nix
    ./fun.nix
    ./editor/default.nix
    ./terminal/default.nix
  ];

  environment.systemPackages = with pkgs; [
    # Utilities
    uutils-coreutils-noprefix
    wget
    parted
    eva
    navi

    # Replacements
    bat # cat
    btop # top
    dust # du
    eza # ls
    ripgrep # grep
    ripgrep-all
    tealdeer # tldr
    rip2 # rm
    frawk # awk
    xcp # cp
    delta # diff
    fd # find
    hexyl # xxd
    xh # curl
    hyperfine # time
    jql # jq

    # Files
    detox
    fzf
    yazi

    # Android Tooling
    android-tools

    # Nix
    nh

    # Windows Compatibility
    ntfs3g
  ];
}
