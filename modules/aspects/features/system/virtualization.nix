{
  den.aspects.virtualization.provides = {
    android.nixos = {
      virtualisation.waydroid.enable = true;
    };
    podman.nixos = {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
      };
      virtualisation.oci-containers.backend = "podman";
    };

    emulate-aarch64.nixos = {
      boot.binfmt.emulatedSystems = ["aarch64-linux"];
    };
  };
}
