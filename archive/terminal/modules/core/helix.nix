{
  inputs,
  osConfig,
  ...
}: {
  home.packages = [
    inputs.conf-helix.packages.${osConfig.my.system.arch}.default
  ];
}
