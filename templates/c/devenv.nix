{pkgs, ...}: {
  # gcc, make, clang-tools, gdb, valgrind
  languages.c = {
    enable = true;
    # helix brings clangd
    lsp.enable = false;
    debugger = pkgs.lldb;
  };

  packages = [
    pkgs.cmake
    pkgs.bear
  ];

  treefmt.config.programs.clang-format.enable = true;

  # compile_commands.json for clangd
  scripts.compdb.exec = ''bear -- make "$@"'';

  enterTest = "make test";
}
