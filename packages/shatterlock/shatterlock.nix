{
  perSystem = {inputs', ...}: {
    # ~/.config/shatterlock/config.json layers on top
    packages.shatterlock = inputs'.shatterlock.packages.default.override {
      settings = {
        # fallback lock; dms ignores loginctl lock-session with logind integration off
        actionDefs.lock.command = ["dms" "ipc" "call" "lock" "lock"];
        # seconds; dms lock timeouts stay 0
        lock.idle = {
          ac = 3600;
          battery = 600;
        };
        # needs the patched niri and its layer rule
        live = true;
      };
    };
  };
}
