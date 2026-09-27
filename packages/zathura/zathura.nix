{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    # The module pins `package` itself, and its default plugin list already
    # carries mupdf. catppuccin's mocha port highlights in mauve
    # (completion-highlight-bg, highlight-active-color), so it goes in as-is.
    packages.zathura = wrappers.wrappers.zathura.wrap [
      {inherit pkgs;}
      {
        extraSettings = ''
          include ${inputs'.catppuccin.packages.zathura}/catppuccin-mocha
        '';
      }
    ];
  };
}
