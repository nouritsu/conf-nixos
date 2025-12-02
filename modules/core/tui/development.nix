{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Bash
    bash

    # Fish
    fish
    fish-lsp

    # JavaScript
    nodejs_22
    deno

    # Nix
    nixd
    alejandra

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
    gh
    lazygit
    lldb
    gnumake
    cmake
    nodePackages_latest.prettier # CSS, HTML
    vscode-langservers-extracted # CSS, HTML
  ];
}
