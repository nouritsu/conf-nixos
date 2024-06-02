{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Common
    gh
    git
    postman
    vscode

    # C/C++
    libgcc

    # Python
    python3

    # Rust
    rustup
    bacon
    pest-ide-tools

    # Node
    nodejs_22
    bun

    # Go
    go

  ];
}
