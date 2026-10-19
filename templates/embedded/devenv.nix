{pkgs, ...}: {
  packages = [
    pkgs.gcc-arm-embedded
    pkgs.gnumake
    pkgs.openocd
    pkgs.stlink
    pkgs.bear
    pkgs.tio
  ];

  # clangd parses with the arm toolchain's headers
  files.".clangd".yaml.CompileFlags = {
    Compiler = "${pkgs.gcc-arm-embedded}/bin/arm-none-eabi-gcc";
    Remove = ["-Wa,*" "-specs=*" "--specs=*"];
  };

  env.OPENOCD_TARGET = "target/stm32u5x.cfg";

  treefmt.config.programs.clang-format.enable = true;

  # compile_commands.json for clangd
  scripts.compdb.exec = ''bear -- make "$@"'';
  scripts.flash.exec = ''
    openocd -f interface/stlink.cfg -f "$OPENOCD_TARGET" \
      -c "program ''${1:-build/firmware.elf} verify reset exit"
  '';

  enterTest = "make";
}
