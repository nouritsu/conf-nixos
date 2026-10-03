{
  # only what DMS has no setting for
  flake.nixosModules.wniri-appearance = {...}: {
    settings = {
      prefer-no-csd = _: {};

      layout.struts = {
        left = 5;
        right = 5;
        top = 5;
        bottom = 5;
      };
    };
  };
}
