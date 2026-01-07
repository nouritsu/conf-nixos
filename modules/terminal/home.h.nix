{
  imports = [
    # by-utility
    ## development
    ./mod/by-utility/development/android.h.nix
    ./mod/by-utility/development/common.h.nix
    ./mod/by-utility/development/git.h.nix
    ./mod/by-utility/development/json.h.nix
    ./mod/by-utility/development/nix.h.nix
    ./mod/by-utility/development/python.h.nix
    ./mod/by-utility/development/regex.h.nix
    ./mod/by-utility/development/rust.h.nix
    ## filesystem
    ./mod/by-utility/filesystem/find.h.nix
    ./mod/by-utility/filesystem/fs.h.nix
    ./mod/by-utility/filesystem/ntfs.h.nix
    ./mod/by-utility/filesystem/stats.h.nix
    ./mod/by-utility/filesystem/yazi.h.nix
    ./mod/by-utility/filesystem/zoxide.h.nix
    ## general
    ./mod/by-utility/general/btop.h.nix
    ./mod/by-utility/general/eva.h.nix
    ./mod/by-utility/general/helix/home.h.nix
    ./mod/by-utility/general/hyperfine.h.nix
    ./mod/by-utility/general/sysfetch.h.nix
    ## help
    ./mod/by-utility/help/help.h.nix
    ./mod/by-utility/help/tealdeer.h.nix
    ## media
    ./mod/by-utility/media/av.h.nix
    ./mod/by-utility/media/bytes.h.nix
    ./mod/by-utility/media/markdown.h.nix
    ./mod/by-utility/media/pdf.h.nix
    ## web
    ./mod/by-utility/web/download.h.nix
    ./mod/by-utility/web/network.h.nix

    # core
    ./mod/core/any-nix-shell.h.nix
    ./mod/core/nixos.h.nix
    ./mod/core/utils.h.nix
    ## prompt
    ./mod/core/prompt/home.h.nix
    ## shell
    ./mod/core/shell/home.h.nix
  ];
}
