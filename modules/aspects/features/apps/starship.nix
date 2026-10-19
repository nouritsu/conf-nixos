{
  den.aspects.starship.nixos = {
    self',
    lib,
    ...
  }: let
    starship = self'.packages.starship;
    settings = starship.configuration.constructFiles."starship.toml".outPath;
    sshSettings = starship.configuration.constructFiles."starship-ssh.toml".outPath;
  in {
    environment.systemPackages = [starship];

    # the prompt runs the wrapper, which only defaults STARSHIP_CONFIG
    programs.fish.interactiveShellInit = ''
      if test "$TERM" != dumb
        if set -q SSH_CONNECTION
          set -gx STARSHIP_CONFIG ${sshSettings}
        else
          set -gx STARSHIP_CONFIG ${settings}
        end

        function starship_transient_prompt_func
          ${lib.getExe starship} module character
        end

        ${lib.getExe starship} init fish | source
        enable_transience
      end
    '';
  };
}
