{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: let
    src = inputs'.dux-plugin-registry.packages.dankRazer;
  in {
    packages.dankrazer = pkgs.buildGoModule {
      pname = "dankrazer";
      inherit (src) version;
      src = "${src}/dankrazer-cli";
      vendorHash = "sha256-+oHslT8yKWaToq2zmVJ+NVowPfRGR6R6ajapFywmgo8=";
      subPackages = ["cmd/dankrazer"];
      # src follows the registry input, only vendorHash is ours
      passthru.nup = ["--version=skip"];
      meta.mainProgram = "dankrazer";
    };
  };
}
