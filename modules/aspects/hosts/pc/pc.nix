{den, ...}: {
  den.aspects.pc = {
    includes = [
      den.aspects.workstation
      den.aspects.kernel.cachyos-bore-lto
    ];
  };
}
