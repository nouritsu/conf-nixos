{
  lib,
  user,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;

    settings = let
      # Colors
      prompt_ok = "purple";
      prompt_err = "red";
      icon = "black";
      separator = "bright-black";
      background = "bright-black";

      directory = "bright-purple";
      duration = "blue";
      status = "red";
      git_branch = "bright-green";
      git_status = "bright-green";
    in {
      add_newline = false;
      format = lib.concatStrings [
        "[╭](fg:${separator})"
        "$status"
        "$directory"
        "$git_branch"
        "$git_status"
        "$cmd_duration"
        "$time"
        "$line_break"
        "[╰](fg:${separator})"
        "[ ](blue)"
        " ${lib.toLower (builtins.elemAt (lib.splitString " " user.name) 0)} "
        "$character"
      ];

      # Status
      character = {
        disabled = false;
        success_symbol = "[❯](fg:${prompt_ok})";
        error_symbol = "[❯](fg:${prompt_err})";
      };

      status = {
        disabled = false;
        format = "[─](fg:${separator})[](fg:${status})[$symbol](fg:${icon} bg:${status})[](fg:${status} bg:${background})[ $status](bg:${background})[](fg:${background})";

        map_symbol = true;
        symbol = " ";
        not_executable_symbol = "󰜺 ";
        not_found_symbol = " ";
        sigint_symbol = " ";
        signal_symbol = "󰰢 ";

        pipestatus = true;
        pipestatus_separator = "-";
        pipestatus_segment_format = "$status";
        pipestatus_format = "[─](fg:${separator})[](fg:${status})[$symbol](fg:${icon} bg:${status})[](fg:${status} bg:${background})[ $pipestatus](bg:${background})[](fg:${background})";
      };

      # Directory

      directory = {
        disabled = false;
        format = "[─](fg:${separator})[](fg:${directory})[ ](fg:${icon} bg:${directory})[](fg:${directory} bg:${background})[ $path](bg:${background})[](fg:${background})";
        truncate_to_repo = true;
        truncation_length = 0;
      };

      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = "󰝚 ";
        "Pictures" = " ";
      };

      # Git
      git_branch = {
        disabled = false;
        format = "[─](fg:${separator})[](fg:${git_branch})[$symbol](fg:${icon} bg:${git_branch})[](fg:${git_branch} bg:${background})[ $branch](bg:${background})";
        symbol = " ";
      };

      git_status = {
        disabled = false;
        format = "[](fg:${background} bg:${git_status})[$all_status$ahead_behind](fg:${icon} bg:${git_status})[](fg:${git_status})";
      };

      # Timing
      cmd_duration = {
        disabled = false;
        format = "[─](fg:${separator})[](fg:${duration})[󱐋](fg:${icon} bg:${duration})[](fg:${duration} bg:${background})[ $duration](bg:${background})[](fg:${background})";
        min_time = 1000;
      };

      time.disabled = true;
    };
  };
}
