{den, ...}: {
  den.aspects.development.includes = with den.aspects; [
    dev
    dev.direnv
    dev.devenv
    dev.android
    dev.embedded
    dev.godot
    dev.nix
    git
    helix
    virtualization.podman
  ];
}
