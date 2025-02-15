{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    clang # Compiler
    clang-tools
  ];
}
