{
  inputs,
  osConfig,
  pkgs,
  ...
}: let
  yazi-pkg = inputs.yazi.packages.${osConfig.my.system.arch}.default;
  yazi = "${yazi-pkg}/bin/yazi";

  plugins = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "plugins";
    rev = "05234ed15876ea80e1f4f05695e8e90c1fd5ab60";
    hash = "sha256-UJ2ICrp9LQBuuR/NpZvKsvFd/C1TRtTjK4ESNA6xh7k=";
  };

  yatline = pkgs.fetchFromGitHub {
    # https://github.com/carlosedp/yatline.yazi
    owner = "carlosedp";
    repo = "yatline.yazi";
    rev = "61d3a3a3310c74dfcf636c76e53ba388a019a3b5";
    hash = "sha256-XLnFRuvU4O5CbF7vO044iU6IXG8ojPyVjVR/8r7MGPc=";
  }; # default does not work on yazi-nightly

  path-from-root = pkgs.fetchFromGitHub {
    # https://github.com/aresler/path-from-root.yazi
    owner = "aresler";
    repo = "path-from-root.yazi";
    rev = "c4f03df864f09f9d2c4d585411f61c64de5954de";
    hash = "sha256-dQjZwRT1aMo3u0YuR+g036iQANTXnndaDQ3AoJ1yb1k=h";
  };
in {
  home.packages = with pkgs; [mediainfo ouch];

  home.shellAliases = {
    fm = "${yazi}";
  };

  programs.yazi = {
    enable = true;
    package = yazi-pkg;
    enableFishIntegration = true;
    enableBashIntegration = true;
    shellWrapperName = "yazi_wrapper";

    plugins = {
      inherit yatline path-from-root;
      yatline-catppuccin = pkgs.yaziPlugins.yatline-catppuccin;
      piper = pkgs.yaziPlugins.piper;
      ouch = pkgs.yaziPlugins.ouch;
      mediainfo = pkgs.yaziPlugins.mediainfo;
      wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
      duckdb = pkgs.yaziPlugins.duckdb;
      full-border = pkgs.yaziPlugins.full-border;
      git = pkgs.yaziPlugins.git;
      zoom = "${plugins}/zoom.yazi";
      smart-filter = "${plugins}/smart-filter.yazi";
      smart-enter = "${plugins}/smart-enter.yazi";
      smart-paste = "${plugins}/smart-paste.yazi";
      mount = "${plugins}/mount.yazi";
    };

    initLua =
      /*
      lua
      */
      ''
        local catppuccin_theme = require("yatline-catppuccin"):setup("mocha")

        require("git"):setup()
        require("duckdb"):setup()
        require("full-border"):setup()

        require("smart-enter"):setup {
        	open_multi = true,
        }

        require("yatline"):setup({
        	theme = catppuccin_theme,
        	section_separator = { open = "", close = "" },
        	part_separator = { open = "", close = "" },
        	inverse_separator = { open = "", close = "" },

        	style_a = {
        		fg = "black",
        		bg_mode = {
        			normal = "white",
        			select = "brightyellow",
        			un_set = "brightred"
        		}
        	},
        	style_b = { bg = "brightblack", fg = "brightwhite" },
        	style_c = { bg = "black", fg = "brightwhite" },

        	permissions_t_fg = "green",
        	permissions_r_fg = "yellow",
        	permissions_w_fg = "red",
        	permissions_x_fg = "cyan",
        	permissions_s_fg = "white",

        	tab_width = 20,
        	tab_use_inverse = false,

        	selected = { icon = "󰻭", fg = "yellow" },
        	copied = { icon = "", fg = "green" },
        	cut = { icon = "", fg = "red" },

        	total = { icon = "󰮍", fg = "yellow" },
        	succ = { icon = "", fg = "green" },
        	fail = { icon = "", fg = "red" },
        	found = { icon = "󰮕", fg = "blue" },
        	processed = { icon = "󰐍", fg = "green" },

        	show_background = true,

        	display_header_line = true,
        	display_status_line = true,

        	component_positions = { "header", "tab", "status" },

        	header_line = {
        		left = {
        			section_a = {
                			{type = "line", custom = false, name = "tabs", params = {"left"}},
        			},
        			section_b = {
        			},
        			section_c = {
        			}
        		},
        		right = {
        			section_a = {
                			{type = "string", custom = false, name = "date", params = {"%A, %d %B %Y"}},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "date", params = {"%X"}},
        			},
        			section_c = {
        			}
        		}
        	},

        	status_line = {
        		left = {
        			section_a = {
                			{type = "string", custom = false, name = "tab_mode"},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "hovered_size"},
        			},
        			section_c = {
                			{type = "string", custom = false, name = "hovered_path"},
                			{type = "coloreds", custom = false, name = "count"},
        			}
        		},
        		right = {
        			section_a = {
                			{type = "string", custom = false, name = "cursor_position"},
        			},
        			section_b = {
                			{type = "string", custom = false, name = "cursor_percentage"},
        			},
        			section_c = {
                			{type = "string", custom = false, name = "hovered_file_extension", params = {true}},
                			{type = "coloreds", custom = false, name = "permissions"},
        			}
        		}
        	},
        })
      '';

    settings = {
      mgr = {
        ratio = [1 2 5];
        show_hidden = true;
        linemode = "none";

        prepend_keymap = [
          {
            on = "M";
            run = "plugin mount";
            desc = "Open Mount Manager";
          }
          {
            on = "p";
            run = "plugin smart-paste";
            desc = "Paste into the hovered directory or CWD";
          }
          {
            on = "l";
            run = "plugin smart-enter";
            desc = "Enter the child directory, or open the file";
          }
          {
            on = "F";
            run = "plugin smart-filter";
            desc = "Smart filter";
          }
          {
            on = ["c" "r"];
            run = "plugin path-from-root";
            desc = "Copies path from git root";
          }
          {
            on = "+";
            run = "plugin zoom 1";
            desc = "Zoom in hovered file";
          }
          {
            on = "-";
            run = "plugin zoom -1";
            desc = "Zoom out hovered file";
          }
          {
            on = ["C"];
            run = "plugin ouch";
            desc = "Compress with ouch";
          }
          {
            on = "<C-y>";
            run = ["plugin wl-clipboard"];
          }
          {
            on = "H";
            run = "plugin duckdb -1";
            desc = "Scroll one column to the left";
          }
          {
            on = "L";
            run = "plugin duckdb +1";
            desc = "Scroll one column to the right";
          }
          {
            on = ["g" "o"];
            run = "plugin duckdb -open";
            desc = "open with duckdb";
          }
          {
            on = ["g" "u"];
            run = "plugin duckdb -ui";
            desc = "open with duckdb ui";
          }
        ];
      };

      plugin = {
        prepend_previewers = [
          {
            name = "*.csv";
            run = "duckdb";
          }
          {
            name = "*.tsv";
            run = "duckdb";
          }
          {
            name = "*.json";
            run = "duckdb";
          }
          {
            name = "*.parquet";
            run = "duckdb";
          }
          {
            name = "*.txt";
            run = "duckdb";
          }
          {
            name = "*.xlsx";
            run = "duckdb";
          }
          {
            name = "*.db";
            run = "duckdb";
          }
          {
            name = "*.duckdb";
            run = "duckdb";
          }
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch";
          }
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
          {
            url = "*.md";
            run = ''piper -- glow -w=$w "$1"'';
          }
        ];
        append_previewers = [
          {
            url = "*";
            run = ''piper -- hexyl --border=none --terminal-width=$w "$1"'';
          }
        ];

        prepend_preloaders = [
          {
            name = "*.csv";
            run = "duckdb";
            multi = false;
          }
          {
            name = "*.tsv";
            run = "duckdb";
            multi = false;
          }
          {
            name = "*.json";
            run = "duckdb";
            multi = false;
          }
          {
            name = "*.parquet";
            run = "duckdb";
            multi = false;
          }
          {
            name = "*.txt";
            run = "duckdb";
            multi = false;
          }
          {
            name = "*.xlsx";
            run = "duckdb";
            multi = false;
          }
          {
            mime = "{audio,video,image}/*";
            run = "mediainfo";
          }
          {
            mime = "application/subrip";
            run = "mediainfo";
          }
          {
            mime = "application/postscript";
            run = "mediainfo";
          }
        ];

        prepend_fetchers = [
          {
            id = "git";
            url = "*";
            run = "git";
          }
          {
            id = "git";
            url = "*/";
            run = "git";
          }
        ];
      };
    };
  };
}
