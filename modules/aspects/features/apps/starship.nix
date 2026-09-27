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

    # `starship init` bakes the path of the binary that ran it into
    # fish_prompt, and that is the unwrapped one, so prompts never pass through
    # the wrapper's STARSHIP_CONFIG. Export the wrapper's config for them.
    # mkAfter keeps this behind any-nix-shell, whose --info-right would
    # otherwise redefine fish_right_prompt over starship's.
    programs.fish.interactiveShellInit = lib.mkAfter ''
      if test "$TERM" != dumb
        set -gx STARSHIP_CONFIG ${settings}
        ${lib.getExe starship} init fish | source
      end
    '';
  };
}
