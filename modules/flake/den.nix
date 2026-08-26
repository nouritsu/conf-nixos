{
  inputs,
  den,
  lib,
  ...
}: {
  imports = [inputs.den.flakeModules.default];

  systems = ["x86_64-linux"];
  den.systems = ["x86_64-linux"];
  den.schema.user.classes = lib.mkDefault ["user" "homeManager"];
}
