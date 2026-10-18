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

        function starship_transient_prompt_func
          ${lib.getExe starship} module character
        end

        ${lib.getExe starship} init fish | source
        enable_transience
      end
    '';
  };
}
