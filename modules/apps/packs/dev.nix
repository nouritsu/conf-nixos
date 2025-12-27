{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Shell
    bash
    fish
    fish-lsp
    any-nix-shell

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
    evcxr

    # Common Development Tools
    git
    gcc
    claude-code
    gh
    jq
    lldb
    gnumake
    nodePackages_latest.prettier # CSS, HTML
    vscode-langservers-extracted # CSS, HTML
  ];
}
