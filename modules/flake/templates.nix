{
  flake.templates = {
    rust = {
      path = ../../templates/rust;
      description = "Rust devenv: stable toolchain, rust-analyzer, bacon, rustfmt and clippy hooks";
    };
    python = {
      path = ../../templates/python;
      description = "Python devenv with uv, venv and ruff";
    };
    c = {
      path = ../../templates/c;
      description = "C/C++ devenv: gcc, make, cmake, clang-tools, bear, lldb";
    };
    typst = {
      path = ../../templates/typst;
      description = "Typst devenv with tinymist and typstyle";
    };
    node = {
      path = ../../templates/node;
      description = "Node devenv: npm, typescript, prettier";
    };
    android = {
      path = ../../templates/android;
      description = "Kotlin/Android devenv: jdk21, gradle, kotlin, android sdk";
    };
    embedded = {
      path = ../../templates/embedded;
      description = "ARM embedded devenv: arm-none-eabi gcc, openocd, stlink, clangd config";
    };
    service = {
      path = ../../templates/service;
      description = "Service devenv: postgres and redis under devenv up";
    };
  };
}
