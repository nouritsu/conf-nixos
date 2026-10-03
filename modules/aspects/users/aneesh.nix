{den, ...}: {
  den.aspects.aneesh = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "fish")
      den.batteries.host-aspects
    ];

    user = {
      description = "Aneesh Bhave";
    };
  };
}
