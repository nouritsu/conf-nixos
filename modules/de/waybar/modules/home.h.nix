{...}: {
  imports = [
    # Hyprland
    ./hyprland/window.h.nix
    ./hyprland/windowcount.h.nix
    ./hyprland/workspaces.h.nix

    # System Monitoring
    ./cpu.h.nix
    ./memory.h.nix
    ./temperature.h.nix

    # Hardware Control
    ./battery.h.nix
    ./backlight.h.nix
    ./bluetooth.h.nix
    ./network.h.nix

    # Utilities
    ./clock.h.nix
    ./pulseaudio.h.nix
    ./idle_inhibitor.h.nix
    ./mpris.h.nix

    # Custom
    ./custom/dividers.h.nix
    ./custom/distro.h.nix
    # ./custom/power_menu.h.nix
  ];
}
