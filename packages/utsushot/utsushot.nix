{
  perSystem = {
    pkgs,
    lib,
    inputs',
    ...
  }: {
    # wl-clipboard-rs is this system's wl-copy
    packages.utsushot = inputs'.utsushot.packages.default.overrideAttrs {
      postInstall = ''
        wrapProgram $out/bin/utsushot \
          --prefix PATH : ${lib.makeBinPath [pkgs.grim pkgs.wl-clipboard-rs pkgs.libnotify]}
      '';
    };
  };
}
