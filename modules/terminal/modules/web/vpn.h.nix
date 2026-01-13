{pkgs, ...}: {
  home.packages = [
    # pkgs.mullvad : provided by system/ module
    pkgs.mullvad-closest
  ];
}
