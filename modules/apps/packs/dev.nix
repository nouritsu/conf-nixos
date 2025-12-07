{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Bash
    bash

    # Fish
    fish
    fish-lsp

    # Nix
    nixd
    alejandra
    any-nix-shell

    # Python
    python3
    black
    ruff

    # Rust
    rustup
    rust-analyzer
    bacon
    trunk

    # TypeScript
    typescript
    typescript-language-server

    # Common Development Tools
    git
    claude-code
    gh
    lazygit
    lldb
    gnumake
    cmake
    nodePackages_latest.prettier # CSS, HTML
    vscode-langservers-extracted # CSS, HTML
  ];
}
