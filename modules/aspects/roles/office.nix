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
    };
  };
}
