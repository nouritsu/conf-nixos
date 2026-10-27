{den, ...}: {
  den.aspects.office = {
    includes = with den.aspects; [
      extra.pdf
      services.printing
    ];

    nixos = {
      self',
      lib,
      ...
    }: {
      programs.onlyoffice = {
        enable = true;
        package = self'.packages.onlyoffice;
      };

      which-key'.menu.o.submenu.o = {
        desc = "OnlyOffice";
        icon = "f0dc8";
        cmd = lib.getExe self'.packages.onlyoffice;
        app-id = "onlyoffice|desktopeditors";
      };
    };
  };
}
