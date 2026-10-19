{
  config,
  pkgs,
  ...
}: {
  languages.rust = {
    enable = true;
    channel = "stable";
    components = ["rustc" "cargo" "clippy" "rustfmt" "rust-analyzer" "rust-src"];
  };

  packages = [pkgs.bacon];

  treefmt.config.programs.rustfmt = {
    enable = true;
    package = config.languages.rust.toolchainPackage;
  };

  git-hooks.hooks.clippy.enable = true;

  scripts.lint.exec = "cargo clippy --all-targets -- -D warnings";

  enterTest = "cargo test";
}
