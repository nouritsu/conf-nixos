{pkgs, ...}: {
  home.packages = with pkgs; [
    bash
    gcc
    jq
    lldb
    gnumake
    claude-code
  ];
}
