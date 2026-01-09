{pkgs, ...}: let
  hyperfine = "${pkgs.hyperfine}/bin/hyperfine";
in {
  home.packages = [
    pkgs.hyperfine
  ];

  home.shellAliases = {
    wtime = "${hyperfine} --runs 1 --warmup 3 --";

    bench = "${hyperfine} --runs 5 --";
    wbench = "${hyperfine} --runs 5 --warmup 3 --";
  };
}
