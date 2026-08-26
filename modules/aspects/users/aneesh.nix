{den, ...}: {
  den.aspects.aneesh = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
    ];

    user = {
      description = "Aneesh Bhave";
    };
  };
}
