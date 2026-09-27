{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # godot-mcp runs `godot` from PATH when GODOT_PATH is unset. Appending this
    # config's Godot keeps a project devShell's version first and still works
    # where no Godot is on PATH.
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
