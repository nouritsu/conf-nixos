{
  # Gaps, focus-ring and border width, corner radius and every colour come from
  # DMS through ./dms.nix. What stays here is what DMS has no setting for.
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
