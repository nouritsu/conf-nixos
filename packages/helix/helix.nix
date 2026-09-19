{
  self,
  inputs,
  ...
}: let
  inherit (inputs) wrappers helix;
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    core = [
      {
        inherit pkgs;
        package = helix.packages.${system}.helix;
      }
      self.nixosModules.whelix-options
    ];

    min =
      core
      ++ [
        self.nixosModules.whelix-settings-editor
        self.nixosModules.whelix-settings-statusline
        self.nixosModules.whelix-settings-theme

        self.nixosModules.whelix-keybinds-core
        self.nixosModules.whelix-keybinds-buffer
        self.nixosModules.whelix-keybinds-easymotion
        self.nixosModules.whelix-keybinds-files
        self.nixosModules.whelix-keybinds-git
        self.nixosModules.whelix-keybinds-incdec
        self.nixosModules.whelix-keybinds-lsp
      ];
  in {
    packages.helix = wrappers.wrappers.helix.wrap (min
      ++ [
        self.nixosModules.whelix-spellcheck

        self.nixosModules.whelix-integrations-lazygit
        self.nixosModules.whelix-integrations-yazi

        self.nixosModules.whelix-lsp-c
        self.nixosModules.whelix-lsp-cook-cli
        self.nixosModules.whelix-lsp-nix
        self.nixosModules.whelix-lsp-python
        self.nixosModules.whelix-lsp-rust
        self.nixosModules.whelix-lsp-slint
        self.nixosModules.whelix-lsp-typst
      ]);

    packages.helix-min =
      wrappers.wrappers.helix.wrap min;
  };
}
