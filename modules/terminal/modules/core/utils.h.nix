{
  pkgs,
  lib,
  ...
}: let
  cd_abbr_count = 7;

  lsd = lib.getExe pkgs.lsd;
  bat = lib.getExe pkgs.bat;
  xcp = lib.getExe pkgs.xcp;
  rip = lib.getExe' pkgs.rip2 "rip";
in {
  home = {
    packages = with pkgs; [
      uutils-coreutils-noprefix
      killall

      nix-output-monitor
    ];

    shellAliases = rec {
      # ls
      ls = "${lsd} -F --total-size --group-directories-first --hyperlink auto --git --extensionsort --classify";
      l = "${ls} -1";
      ll = "${ls} -lA";
      lr = "${ll} --recursive";
      tree = "${ls} --tree";

      cat = "${bat} --theme=ansi"; # inherit terminal theme

      cp = xcp;

      rm = "${rip} --inspect";
    };
  };

  # form: abbr = expansion
  programs.fish.shellAbbrs = lib.listToAttrs (
    map (n: {
      name = lib.concatStrings (lib.genList (_: ".") n); # n dots
      value = "cd ${lib.concatStringsSep "/" (lib.genList (_: "..") (n - 1))}"; # prev_dir based on n
    }) (lib.range 2 (cd_abbr_count + 1))
  );
}
