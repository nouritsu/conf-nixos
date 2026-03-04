{
  flake.nixosModules = {
    virt-podman = {...}: {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
      };
      virtualisation.oci-containers.backend = "podman";
    };

    virt-emulate-aarch64 = {
      boot.binfmt.emulatedSystems = ["aarch64-linux"];
    };

    virt-waydroid = {pkgs, ...}: {
      virtualisation.waydroid = {
        enable = true;
        package = pkgs.waydroid-nftables;
      };

      boot.specialFileSystems."/dev/binderfs" = {
        device = "binder";
        fsType = "binder";
        options = ["max=1024"];
      };
    };
  };
}
