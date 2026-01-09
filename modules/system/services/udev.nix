{
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="777", GROUP="input", OPTIONS+="static_node=uinput"
  '';
}
