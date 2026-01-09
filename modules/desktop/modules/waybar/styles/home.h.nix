{
  config,
  lib,
  ...
}: let
  cfg = config.my.waybar.styles;
  common_css =
    /*
    css: common
    */
    ''
      * {
        color: @main-fg;
      	font-family: "JetBrainsMono Nerd Font Propo";
      	font-weight: bold;
      	font-size: 12pt;
      }

      .module {
        margin-bottom: -1px;
      }

      #waybar {
        background-color: @outline;
      }

      #waybar>box {
        margin: 4px;
        background-color: @main-bg;
      }

      button {
        border-radius: 16px;
        min-width: 16px;
        padding: 0 10px;
      }

      button:hover {
        background-color: @hover-bg;
        color: @hover-fg;
      }

      tooltip {
        border: 2px solid @main-br;
        border-radius: 10px;
        background-color: @main-bg;
      }

      tooltip>box {
        padding: 0 6px;
      }

      #custom-divr,
      #custom-divri,
      #custom-divre,
      #custom-divl,
      #custom-divli,
      #custom-divle {
        font-size: 22px;
      }
    '';
in {
  imports = [
    ./colours.h.nix
  ];

  programs.waybar.style = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
    cfg.define_parts
    common_css
    cfg.parts
  ]);
}
