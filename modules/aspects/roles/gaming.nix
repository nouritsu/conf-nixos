{den, ...}: {
  # What any host that games gets. Mod managers and emulators ride on the
  # workstation role, Razer tools on pc with the rest of its desk hardware.
  den.aspects.gaming.includes = with den.aspects; [
    extra.gaming
    peripherals.controller
  ];
}
