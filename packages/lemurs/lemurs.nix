{
  perSystem = {pkgs, ...}: {
    # main: 0.4.0 opens the session in lemurs itself, so logind gives it no seat and a second login hangs
    packages.lemurs = pkgs.rustPlatform.buildRustPackage {
      pname = "lemurs";
      version = "0.4.0-unstable-2026-10-13";

      src = pkgs.fetchFromGitHub {
        owner = "coastalwhite";
        repo = "lemurs";
        rev = "2b25ec2db27c76255ad0bc527bf764a5696b660f";
        hash = "sha256-HHTegcXjLpETMPLHVL8TOObSb9/FwtFf8+hArVvstGE=";
      };

      cargoHash = "sha256-7mSzw1pkejMeEnvYzTaleR7wJtPIIHlw7/Rm9GqTWjQ=";

      buildInputs = [pkgs.linux-pam];

      postInstall = ''
        install -Dm0755 extra/xsetup.sh "$out/etc/xsetup.sh"
      '';

      passthru.nup = ["--version=branch"];

      inherit (pkgs.lemurs) meta;
    };
  };
}
