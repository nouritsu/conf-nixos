# the touch notification: dux draws material: icons itself, in its own colours,
# and lets critical ones through do not disturb
_: prev: {
  yubikey-touch-detector = prev.yubikey-touch-detector.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace notifier/libnotify.go \
          --replace-warn 'AppIcon: "yubikey-touch-detector"' 'AppIcon: "material:key"' \
          --replace-fail 'notification.AddHint(notify.Hint{ID: "transient", Variant: dbus.MakeVariant(true)})' \
            'notification.AddHint(notify.Hint{ID: "transient", Variant: dbus.MakeVariant(true)}); notification.AddHint(notify.Hint{ID: "urgency", Variant: dbus.MakeVariant(byte(2))})'
      '';
  });
}
