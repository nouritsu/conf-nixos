{pkgs}: let
  named = {
    name,
    bin,
  }: "${pkgs.${name}}/bin/${bin}";
in {
  inherit named;

  default = pkg:
    named {
      name = pkg;
      bin = pkg;
    };
}
