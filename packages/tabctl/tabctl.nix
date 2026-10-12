{
  perSystem = {pkgs, ...}: {
    packages.tabctl = pkgs.buildGoModule rec {
      pname = "tabctl";
      version = "2.3.0";

      src = pkgs.fetchFromGitHub {
        owner = "slastra";
        repo = "tabctl";
        rev = "v${version}";
        hash = "sha256-HQe52OW4PsTS5PlCxZwJVMYB8mHrz9DAsCHbgNa+X84=";
      };

      vendorHash = "sha256-oSt9bwhTf4EBeWhgb6sXvGJK7B75MGya4Gp2nMPqgDM=";

      subPackages = ["cmd/tabctl" "cmd/tabctl-mediator"];

      ldflags = ["-X github.com/tabctl/tabctl/internal/config.Version=${version}"];

      meta = {
        description = "Control browser tabs from the command line";
        homepage = "https://github.com/slastra/tabctl";
        license = pkgs.lib.licenses.mit;
        platforms = pkgs.lib.platforms.linux;
        mainProgram = "tabctl";
      };
    };
  };
}
