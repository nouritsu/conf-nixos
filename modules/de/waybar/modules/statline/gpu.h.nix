{
  pkgs,
  waybar_lib,
  ...
}: let
  terminal-launch = "${pkgs.wezterm}/bin/wezterm-gui start";
  nvtop = "${pkgs.nvtopPackages.nvidia}/bin/nvtop"; # change based on gpu
  jq = "${pkgs.jq}/bin/jq";
  head = "${pkgs.coreutils}/bin/head";

  waybar-gpu-usage = let
    gpu-usage-waybar = "${pkgs.gpu-usage-waybar}/bin/gpu-usage-waybar";
  in
    pkgs.writeShellScript "waybar-gpu-usage" ''
      ( ${gpu-usage-waybar} & ) 2>/dev/null | ${head} -n 1 | ${jq} -c '
        (.text | split("|")[0]) as $gpu |
        (.text | split("|")[1]) as $vram |
        (.tooltip | match("TEMP: ([0-9]+)") | .captures[0].string) as $temp |
        .text = "\($gpu)     \($vram)   \($temp)°C"
      '
    '';
in {
  programs.waybar.settings.default."custom/gpu" = {
    format = "{icon} {text}";
    exec = waybar-gpu-usage;
    return-type = "json";
    format-icons = "󰾲 ";
    on-click = "${terminal-launch} ${nvtop}";
    interval = 15;
    max-length = 21;
  };

  my.waybar.styles = {
    define_parts = waybar_lib.mk_batch_defines [
      "gpu-fg: @surface0"
      "gpu-bg: @green"
    ];

    parts =
      /*
      css
      */
      ''
        #custom-gpu {
          color: @gpu-fg;
          background-color: @gpu-bg;
          padding-left: 6px;
          padding-right: 10px;
        }
      '';
  };
}
