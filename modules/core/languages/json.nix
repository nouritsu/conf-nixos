{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    jql
  ];
}
