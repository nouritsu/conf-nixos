{...}: {
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  services.printing.enable = true;

<<<<<<< HEAD
=======
  security.rtkit.enable = true;

>>>>>>> c2eab88 (get system to a working state)
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  services.automatic-timezoned.enable = true;
}
