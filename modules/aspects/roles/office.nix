{den, ...}: {
  den.aspects.office = {
    includes = with den.aspects; [
      extra.pdf
      services.printing
    ];

    nixos = {self', ...}: {
      programs.onlyoffice = {
        enable = true;
        package = self'.packages.onlyoffice;
      };

      which-key'.menu.o.submenu.o = {
        desc = "OnlyOffice";
        icon = "f0dc8";
        # the module's build, the one with the system fonts
        cmd = "onlyoffice-desktopeditors";
        app-id = "onlyoffice|desktopeditors";
      };
    };
  };
}
