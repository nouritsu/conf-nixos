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
    programs.fish.interactiveShellInit = ''
      if test "$TERM" != dumb
        set -gx STARSHIP_CONFIG ${settings}
        ${lib.getExe starship} init fish | source
      end
    '';
  };
}
