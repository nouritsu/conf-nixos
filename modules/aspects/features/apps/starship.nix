{
  den.aspects.starship.nixos = {
    self',
    lib,
    ...
  }: let
    starship = self'.packages.starship;
    settings = starship.configuration.constructFiles."starship.toml".outPath;
  in {
    environment.systemPackages = [starship];

    # starship init bakes in the unwrapped binary, so export its config here
    # mkAfter: any-nix-shell would clobber fish_right_prompt
    programs.fish.interactiveShellInit = lib.mkAfter ''
      if test "$TERM" != dumb
        set -gx STARSHIP_CONFIG ${settings}
        ${lib.getExe starship} init fish | source
      end
    '';
  };
}
