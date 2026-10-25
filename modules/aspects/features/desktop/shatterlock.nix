{
  den.aspects.shatterlock = {
    # refuses to lock without its pam service
    nixos = {...}: {
      security.pam.services.shatterlock = {};
    };
  };
}
