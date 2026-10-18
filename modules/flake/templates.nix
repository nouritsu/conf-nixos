{
  flake.templates = {
    rust = {
      path = ../../templates/rust;
      description = "Rust devshell: stable toolchain from rust-overlay, rust-analyzer, bacon";
    };
    python = {
      path = ../../templates/python;
      description = "Python devshell with uv";
    };
    c = {
      path = ../../templates/c;
      description = "C/C++ devshell: gcc, make, cmake, clangd, bear, lldb";
    };
    typst = {
      path = ../../templates/typst;
      description = "Typst devshell with tinymist and typstyle";
    };
  };
}
