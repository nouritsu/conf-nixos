{
  perSystem = {inputs', ...}: {
    # ~/.config/shatterlock/config.json layers on top
    packages.shatterlock = inputs'.shatterlock.packages.default.overrideAttrs (old: {
      # per-host settings, written by the shatterlock aspect
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/shatterlock --set SHATTERLOCK_SETTINGS /etc/shatterlock/settings.json
        '';
    });
  };
}
