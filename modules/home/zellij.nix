{...}: {
  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    settings = {
      default_shell = "fish";
      auto_layout = true;
      default_layout = "compact";
      mouse_mode = false; # enable once comfortable
      ui.pane_frames = {
        rounded_corners = true;
        hide_session_name = true;
      };
    };
  };
}
