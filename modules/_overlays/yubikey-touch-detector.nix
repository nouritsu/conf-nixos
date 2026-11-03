# the touch notification's icon; dux draws material: icons itself, in its own colours
_: prev: {
  yubikey-touch-detector = prev.yubikey-touch-detector.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        substituteInPlace notifier/libnotify.go \
          --replace-warn 'AppIcon: "yubikey-touch-detector"' 'AppIcon: "material:key"'
      '';
  });
}
