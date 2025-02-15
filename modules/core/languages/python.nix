{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    python3
    black # Formatter
  ];
}
