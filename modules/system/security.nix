{
  flake.nixosModules = {
    security-keyring = {pkgs, ...}: {
      my.hmModules = ["security-keyring"];

      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.login.enableGnomeKeyring = true; # for TTYs etc.

      environment.systemPackages = [
        pkgs.gcr_4
        pkgs.seahorse
      ];
    };

    security-polkit = {pkgs, ...}: {
      my.hmModules = ["security-polkit"];

      security.polkit.enable = true;

      environment.systemPackages = [
        pkgs.polkit_gnome
      ];
    };

    security-rtkit = {...}: {
      security.rtkit.enable = true;
    };
  };

  flake.homeModules = {
    security-keyring = {...}: {
      wayland.windowManager.hyprland.settings.exec-once = [
        "gnome-keyring-daemon --start --components=secrets,pkcs11,ssh"
      ];
    };

    security-polkit = {pkgs, ...}: {
      wayland.windowManager.hyprland.settings.exec-once = [
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];
    };
  };
}
