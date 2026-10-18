{
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.balatro-sync = pkgs.writers.writeFishBin "balatro-sync" {
      makeWrapperArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath [
          pkgs.gum
          pkgs.android-tools
          pkgs.luajit
          pkgs.python3
          pkgs.unzip
          pkgs.gnutar
          pkgs.procps
          pkgs.coreutils
        ])
      ];
    } (builtins.replaceStrings ["@merge@" "@verify@"] ["${./merge.lua}" "${./verify.lua}"] (builtins.readFile ./balatro-sync.fish));
  };
}
