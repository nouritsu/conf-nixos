{
  flake.nixosModules.whelix-keybinds-git = {pkgs, ...}: let
    # author, date and summary of the commit behind a line
    blame = pkgs.writeShellScript "hx-blame" ''
      dir=$(dirname -- "$1")
      sha=$(git -C "$dir" blame -L "$2,+1" --porcelain -- "$1" 2>/dev/null | head -n1 | cut -d' ' -f1)
      git -C "$dir" show -s --format='%an, %as: %s' "$sha" 2>/dev/null || echo "not committed yet"
    '';
  in {
    helix'.binds_g =
      /*
      toml
      */
      ''
        c = "goto_next_change"
        C = "goto_prev_change"
      '';

    helix'.binds_space =
      /*
      toml
      */
      ''
        c = "changed_file_picker"
        B = ":echo %sh{${blame} '%{file_path_absolute}' %{cursor_line}}"
        O = ":sh gh browse %{buffer_name}:%{cursor_line}"
      '';
  };
}
