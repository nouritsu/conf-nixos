{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # appended, so a devShell's Godot still wins
    packages.godot-mcp = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.godot-mcp;
      }
      {
        suffixVar = [["PATH" ":" "${self'.packages.godot}/bin"]];
      }
    ];
  };
}
