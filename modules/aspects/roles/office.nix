{den, ...}: {
  den.aspects.office = {
    includes = with den.aspects; [
      extra.pdf
      services.printing
    ];

    nixos = {pkgs, ...}: {
      environment.systemPackages = [pkgs.libreoffice-fresh];
    };
  };
}
