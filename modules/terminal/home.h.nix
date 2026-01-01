{
  imports = [
    # by-utility
    ## development
    ./mods/by-utility/development/android.h.nix
    ./mods/by-utility/development/common.h.nix
    ./mods/by-utility/development/git.h.nix
    ./mods/by-utility/development/json.h.nix
    ./mods/by-utility/development/nix.h.nix
    ./mods/by-utility/development/python.h.nix
    ./mods/by-utility/development/regex.h.nix
    ./mods/by-utility/development/rust.h.nix
    ## filesystem
    ./mods/by-utility/filesystem/find.h.nix
    ./mods/by-utility/filesystem/fs.h.nix
    ./mods/by-utility/filesystem/ntfs.h.nix
    ./mods/by-utility/filesystem/stats.h.nix
    ./mods/by-utility/filesystem/yazi.h.nix
    ./mods/by-utility/filesystem/zoxide.h.nix
    ## general
    ./mods/by-utility/general/btop.h.nix
    ./mods/by-utility/general/eva.h.nix
    ./mods/by-utility/general/helix.h.nix
    ./mods/by-utility/general/hyperfine.h.nix
    ./mods/by-utility/general/sysfetch.h.nix
    ## help
    ./mods/by-utility/help/help.h.nix
    ./mods/by-utility/help/tealdeer.h.nix
    ## media
    ./mods/by-utility/media/av.h.nix
    ./mods/by-utility/media/bytes.h.nix
    ./mods/by-utility/media/markdown.h.nix
    ./mods/by-utility/media/pdf.h.nix
    ## web
    ./mods/by-utility/web/download.h.nix
    ./mods/by-utility/web/network.h.nix

    # core
    ./mods/core/any-nix-shell.h.nix
    ./mods/core/nixos.h.nix
    ./mods/core/utils.h.nix
    ## prompt
    ./mods/core/prompt/home.h.nix
    ## shell
    ./mods/core/shell/home.h.nix
  ];
}
