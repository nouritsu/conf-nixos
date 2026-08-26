{
  flake.nixosModules.wyazi-keymap = {...}: {
    settings.keymap.mgr.prepend_keymap = [
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
}
