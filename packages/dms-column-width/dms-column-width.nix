{
  perSystem = {
    pkgs,
    self',
    ...
  }: let
    # niri's struts, for the widget's working area
    inherit (self'.packages.niri.configuration.settings.layout) struts;
  in {
    # dms widget: the focused column's width as a % of the screen
    packages.dms-column-width = pkgs.runCommand "dms-column-width" {} ''
      mkdir $out
      cp ${./plugin.json} $out/plugin.json
      substitute ${./ColumnWidthWidget.qml} $out/ColumnWidthWidget.qml --replace-fail @struts@ ${toString (struts.left + struts.right)}
    '';
  };
}
