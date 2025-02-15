{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    ...
  } @ inputs: {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          nixos-wsl.nixosModules.default
          ./hosts/wsl.nix
          ./modules/default.nix
          inputs.nixvim.nixosModules.nixvim
        ];

        specialArgs = {
          inherit inputs;

          supported_languages = [
            # Programming Languages
            "c_cpp"
            "go"
            "javascript"
            "nix"
            "python"
            "rust"

            # Other Languages
            "json"
          ];

          user = {
            name = "Aneesh Bhave";
            email = "aneesh1701@gmail.com";
            alias = "aneesh";
          };

          gui = false;
        };
      };
    };
  };
}
