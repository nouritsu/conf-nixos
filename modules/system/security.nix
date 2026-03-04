{
  flake.nixosModules = {
    security-keyring = {...}: {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      security.pam.services.login.enableGnomeKeyring = true; # for TTYs etc.
    };

    security-polkit = {...}: {
      security.polkit.enable = true;
    };

    security-rtkit = {...}: {
      security.rtkit.enable = true;
    };
  };
}
