{
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    # niri's struts, for the widget's working area
    inherit (self'.packages.niri.configuration.settings.layout) struts;
  in {
    # dux widget: the focused window's width and height as a % of the screen
    packages.dux-column-width = pkgs.runCommand "dux-column-width" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      substitute ${./ColumnWidthWidget.qml} $out/ColumnWidthWidget.qml \
        --replace-fail @strutsX@ ${toString (struts.left + struts.right)} \
        --replace-fail @strutsY@ ${toString (struts.top + struts.bottom)}
    '';
  };
}
