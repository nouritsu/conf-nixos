{
  lib,
  user,
  pkgs,
  ...
}: {
  programs.starship = {
    enable = true;

    settings = let
      symbols = {
        status = {
          success = " ";
          failure = " ";
          not_executable = " ";
          not_found = " ";
          sig_int = " ";
          signal = "󱐋";
        };
        separator = "//";
        separator_bottom = "─";
        character = rec {
          success = "❯";
          error = success;
        };
        directory = {
          read_only = " ";
          truncation = "(..)/";
        };
        battery = {
          full = "󰁹";
          charging = "󰂄";
          unknown = "󰂑";
          empty = "󰂎";

          "10" = "󰁺";
          "20" = "󰁻";
          "30" = "󰁼";
          "40" = "󰁽";
          "50" = "󰁾";
          "60" = "󰁿";
          "70" = "󰂀";
          "80" = "󰂁";
          "90" = "󰂂";
        };

        languages = {
          c = " ";
          python = " ";
          nix = "󱄅 ";
          go = " ";
          rust = " ";
          node = "󰎙 ";
        };

        package = " ";

        git_branch = " ";

        memory_usage = " ";

        nix_shell = " ";
      };

      colors = {
        status = {
          default = "bold red";
          success = "bold blue";
          failure = "bold bright-red";
        };
        os = "bold blue";
        character = {
          success = "bold black";
          error = "bold red";
        };
        username = {
          user = "purple bold";
          root = "red bold";
        };
        hostname = "bold green";
        directory = {
          default = "bold green";
          read_only = "bold red";
        };
        separator = "bold black";

        time = "bold yellow";

        cmd_duration = "bold yellow";

        battery = {
          full = "bold bright-green";
          charging = "bold bright-blue";
          discharging = "bold red";
          unknown = "bold yellow";
          empty = "bold black";

          "10" = "bold red";
          "20" = "bold red";
          "30" = "bold bright-red";
          "40" = "bold yellow";
          "50" = "bold yellow";
          "60" = "bold bright-yellow";
          "70" = "bold green";
          "80" = "bold green";
          "90" = "bold bright-green";
        };

        languages = {
          c = "bold blue";
          python = "bold yellow";
          nix = "bold blue";
          go = "bold cyan";
          rust = "bold bright-red";
          node = "bold green";
        };

        package = "bold bright-yellow";

        git_branch = "bold bright-purple";

        git_metrics = {
          added = "bold green";
          deleted = "bold red";
        };

        jobs = "bold bright-purple";

        memory_usage = {
          memory = "bold yellow";
          percent = "bold black";
        };

        nix_shell = {
          default = "bold blue";
          state = "bold red";
        };
      };

      styled = {
        separator = "[${symbols.separator}](${colors.separator})";
        separator_bottom = "[${symbols.separator_bottom}](${colors.separator})";
      };

      to_display = percentage: {
        threshold = percentage;
        style = colors.battery.${builtins.toString percentage};
        symbol = symbols.battery.${builtins.toString percentage};
      };

      replicate = n: str: lib.concatStrings (lib.replicate n str);
      surround = using_l: using_r: color: padding: this: "[\\${using_l}](${color})${replicate padding " "}${this}${replicate padding " "}[\\${using_r}](${color})";
      surround_paren = this: color: padding: surround "(" ")" color padding this;
      surround_bracket = this: color: padding: surround "[" "]" color padding this;
    in {
      add_newline = true;
      command_timeout = 2000;

      format = lib.concatStrings [
        "[╭](${colors.separator})"
        "$status"
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_metrics"
        "$fill$time$cmd_duration"
        "$battery"
        "$line_break"
        "[╰](${colors.separator})"
        "$memory_usage"
        "$nix_shell"
        "$jobs"
        "$character"
      ];

      right_format = lib.concatStrings [
        "$line_break"
        "$c$python$nix$golang$rust$node"
        "$package"
      ];

      fill = {
        disabled = false;
        symbol = " ";
      };

      character = {
        disabled = false;
        success_symbol = "[${symbols.character.success}](${colors.character.success})";
        error_symbol = "[${symbols.character.error}](${colors.character.error})";
      };

      line_break = {
        disabled = false;
      };

      battery = {
        disabled = false;

        format = "${styled.separator} [$symbol$percentage%]($style) ";

        full_symbol = symbols.battery.full;
        charging_symbol = symbols.battery.charging;
        unknown_symbol = symbols.battery.unknown;
        empty_symbol = symbols.battery.empty;

        display =
          map
          to_display [
            10
            20
            30
            40
            50
            60
            70
            80
            90
          ];
      };

      status = {
        disabled = false;
        format = "[$symbol$signal_name$maybe_int]($style) ";

        style = colors.status.default;
        success_style = colors.status.success;
        failure_style = colors.status.failure;

        symbol = symbols.status.failure;
        success_symbol = symbols.status.success;
        not_executable_symbol = symbols.status.not_executable;
        not_found_symbol = symbols.status.not_found;
        sigint_symbol = symbols.status.sig_int;
        signal_symbol = symbols.status.signal;

        map_symbol = true;
        recognize_signal_code = true;
      };

      time = {
        disabled = false;
        style = colors.time;
        format = "[$time]($style) ";
        time_format = "(%A) %R";
      };

      username = {
        disabled = false;
        show_always = true;
        style_user = colors.username.user;
        style_root = colors.username.root;
        format = "${styled.separator} [$user]($style) ";
      };

      hostname = {
        disabled = false;
        ssh_only = false;
        style = colors.hostname;

        format = "${styled.separator} [$hostname](bold blue) ";
      };

      directory = {
        disabled = false;

        format = "${styled.separator} [$path]($style) [$read_only]($read_only_style) ";
        style = colors.directory.default;

        truncation_length = 3;
        truncate_to_repo = false;
        truncation_symbol = symbols.directory.truncation;

        read_only = symbols.directory.read_only;
        read_only_style = colors.directory.read_only;
      };

      c = {
        disabled = false;
        format = "${symbols.languages.c}\\($name-$version\\)]($style) ";
        style = colors.languages.c;
      };

      python = {
        disabled = false;
        format = "${symbols.languages.python}\\($version\\)]($style) ";
        style = colors.languages.python;
      };

      golang = {
        disabled = false;
        format = "${symbols.languages.go}\\($version\\)]($style) ";
        style = colors.languages.go;
      };

      rust = {
        disabled = false;
        format = "${symbols.languages.rust}\\($version\\)]($style) ";
        style = colors.languages.rust;
      };

      nodejs = {
        disabled = false;
        format = "${symbols.languages.node}\\($version\\)]($style) ";
        style = colors.languages.node;
      };

      package = {
        disabled = false;
        format = "${styled.separator} [${symbols.package}\\($version\\)]($style) ";
        style = colors.package;
      };

      cmd_duration = {
        disabled = false;
        min_time = 1000;
        format = "${styled.separator} took [$duration]($style) ";
        show_milliseconds = true;
        style = colors.cmd_duration;
      };

      git_branch = {
        disabled = false;
        format = "${styled.separator} [$symbol$branch(:$remote_branch)]($style) ";
        symbol = symbols.git_branch;
        style = colors.git_branch;
        ignore_branches = ["master" "main"];
      };

      git_metrics = {
        disabled = false;
        only_nonzero_diffs = false;
        format = "${styled.separator} ${surround_bracket "[+$added]($added_style) [-$deleted]($deleted_style)" colors.separator 1} ";
        added_style = colors.git_metrics.added;
        deleted_style = colors.git_metrics.deleted;
      };

      jobs = rec {
        disabled = false;
        format = "${styled.separator_bottom}${surround_paren "[+$number]($style)" colors.separator 0}";
        symbol = "";
        style = colors.jobs;
        number_threshold = 1;
        symbol_threshold = number_threshold;
      };

      memory_usage = {
        disabled = false;
        format = "${styled.separator_bottom}${surround_paren "[$symbol](${colors.memory_usage.memory})[$ram_pct]($style)" colors.separator 0}";
        symbol = symbols.memory_usage;
        style = colors.memory_usage.percent;
        threshold = 50;
      };

      nix_shell = {
        disabled = false;
        format = "${styled.separator_bottom}${surround_bracket "[$symbol$state]($style)[$state](${colors.nix_shell.state})" colors.separator 0}";
        symbol = symbols.nix_shell;
        style = colors.nix_shell.default;
      };
    };
  };
}
