{
  # git and jujutsu both read user.{name,email}, so both wrappers take this
  flake.nixosModules.wgit-identity.settings.user = {
    name = "Aneesh Bhave";
    email = "aneesh1701@gmail.com";
  };
}
