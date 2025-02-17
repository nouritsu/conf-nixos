{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Bash
    bash
    bash-language-server
    beautysh

    # C/C++
    clang
    clang-tools

    # CMake
    cmake
    cmake-format
    cmake-language-server

    # Dart
    dart
    flutter

    # Docker
    docker
    docker-ls
    docker-gc
    dockerfile-language-server-nodejs

    # Dot
    graphviz
    dot-language-server

    # Fish
    fish
    fish-lsp

    # GD Script
    godot_4
    gdtoolkit_4

    # Go
    go
    gopls
    delve

    # Haskell
    ghc
    cabal-install
    cabal2nix
    haskell-language-server

    # Java
    jdk
    jdt-language-server
    google-java-format

    # JavaScript
    nodejs_22
    deno

    # JSON
    jql

    # Kotlin
    kotlin
    kotlin-language-server
    ktfmt

    # LaTeX
    texliveMinimal
    texlab

    # Lua
    lua
    lua-language-server
    stylua

    # Markdown
    marksman
    markdownlint-cli

    # Nix
    nixd
    alejandra

    # GLSL
    glsl_analyzer
    glslviewer

    # Perl
    perl
    perlnavigator
    perl540Packages.PerlTidy

    # Prolog
    ciao
    swi-prolog

    # Python
    python3
    black
    ruff

    # Rust
    cargo
    rustc
    rustfmt
    rust-analyzer
    bacon

    # SQL
    sqls
    sqlfluff

    # TypeScript
    typescript
    typescript-language-server

    # WGSL
    wgsl-analyzer

    # YAML
    yaml-language-server

    # Zig
    zig
    zls

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
