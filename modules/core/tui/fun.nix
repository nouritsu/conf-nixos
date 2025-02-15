{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cowsay
    nerdfetch
    sl
  ];
}
