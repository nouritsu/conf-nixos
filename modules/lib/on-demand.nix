{
  # project lsps: the devshell's copy, else fetched on first use
  flake.lib.onDemand = pkgs: pkg: bin:
    toString (pkgs.writeShellScript bin ''
      if command -v ${bin} > /dev/null; then
        exec ${bin} "$@"
      fi
      exec nix shell nixpkgs#${pkg} -c ${bin} "$@"
    '');
}
