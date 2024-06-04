{ ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    viAlias = true;
    vimAlias = true;

    configure.customRC = ''
      set rnu
      set tabstop=4
      set shiftwidth=4
    '';
  };
}
