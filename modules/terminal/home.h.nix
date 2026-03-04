{
  imports = [
    # core
    modules/core/helix.nix
    modules/core/nixos.h.nix
    modules/core/utils.h.nix

    # development
    modules/development/android.h.nix
    modules/development/common.h.nix
    modules/development/git.h.nix
    modules/development/typst.h.nix
    modules/development/direnv.h.nix
    modules/development/nix.h.nix
    modules/development/python.h.nix
    modules/development/regex.h.nix
    modules/development/rust.h.nix
    modules/development/docker.h.nix
    modules/development/binsider.h.nix

    # filesystem
    modules/filesystem/find.h.nix
    modules/filesystem/fs.h.nix
    modules/filesystem/ntfs.h.nix
    modules/filesystem/stats.h.nix
    modules/filesystem/yazi.h.nix
    modules/filesystem/zoxide.h.nix

    # general
    modules/general/btop.h.nix
    modules/general/eva.h.nix
    modules/general/hyperfine.h.nix
    modules/general/compress.h.nix
    modules/general/sysfetch.h.nix

    # help
    modules/help/help.h.nix
    modules/help/tealdeer.h.nix

    # media
    modules/media/av.h.nix
    modules/media/bytes.h.nix
    modules/media/markdown.h.nix
    modules/media/pdf.h.nix

    # prompt
    modules/prompt/home.h.nix

    # shell
    modules/shell/any-nix-shell.h.nix
    modules/shell/home.h.nix

    # web
    modules/web/download.h.nix
    modules/web/network.h.nix
  ];
}
