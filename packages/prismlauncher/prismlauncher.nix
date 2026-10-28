{
  perSystem = {pkgs, ...}: {
    # every instance is 1.12.2
    packages.prismlauncher = pkgs.prismlauncher.override {jdks = [pkgs.jdk8];};
  };
}
