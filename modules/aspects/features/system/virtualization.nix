{
  den.aspects.virtualization.provides = {
    android.nixos = {
      virtualisation.waydroid.enable = true;

      which-key'.menu.t.submenu.w = {
        desc = "Waydroid";
        icon = "f0032";
        cmd = "waydroid";
        app-id = "^waydroid$";
      };
    };
    podman.nixos = {
      virtualisation.podman = {
        enable = true;
        autoPrune.enable = true;
        dockerCompat = true;
      };

      # docker API clients reach podman's user socket
      environment.variables.DOCKER_HOST = "unix://\${XDG_RUNTIME_DIR}/podman/podman.sock";
      virtualisation.oci-containers.backend = "podman";
    };

    emulate-aarch64.nixos = {
      boot.binfmt.emulatedSystems = ["aarch64-linux"];
    };
  };
}
