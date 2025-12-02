{
  inputs,
  pkgs,
  ...
}: {
  programs.yazi = {
    enable = true;
    package = inputs.yazi.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
}
