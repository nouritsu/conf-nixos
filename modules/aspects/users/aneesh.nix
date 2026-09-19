{den, ...}: {
  den.aspects.aneesh = {
    includes = [
      den.batteries.primary-user
      (den.batteries.user-shell "fish")

      # Projects every `user` and `homeManager` key found in the host's aspect
      # tree onto this user, so features can carry their own home config
      # instead of reaching into den.aspects.aneesh by name.
      den.batteries.host-aspects
    ];

    user = {
      description = "Aneesh Bhave";
    };
  };
}
