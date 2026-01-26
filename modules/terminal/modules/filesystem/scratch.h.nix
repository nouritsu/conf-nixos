{
  pkgs,
  osConfig,
  ...
}: let
  SCRATCH_DIR = "/home/${osConfig.my.user.alias}/scratch";

  scratch-file = pkgs.writeShellApplication {
    name = "scratch-file";
    runtimeInputs = [
      pkgs.gum
      pkgs.coreutils
    ];
    text = ''
      set -euo pipefail

      SCRATCH_DIR="${SCRATCH_DIR}"
      SCRATCH_FILES_DIR="$SCRATCH_DIR/files"

      mkdir -p "$SCRATCH_FILES_DIR"
      mkdir -p "$SCRATCH_DIR/directories"

      temp_file=$(mktemp)

      $EDITOR "$temp_file"

      if [[ ! -s "$temp_file" ]]; then
        rm -f "$temp_file"
        echo "scratch file empty, not saving"
        exit 0
      fi

      if gum confirm "save scratch file?"; then
        default_timestamp=$(date +"%Y-%m-%dT%H:%M")
        filetag=$(gum input --placeholder "tag (optional)" --value "")

        filename="$default_timestamp.txt"
        if [[ -n "$filename" ]]; then
          filename="$default_timestamp-$filetag.txt"
        fi

        target_path="$SCRATCH_FILES_DIR/$filename"
        cp "$temp_file" "$target_path"

        saved_path=$(printf "\e]8;;file://%s\e\\%s\e]8;;\e" \
            "$(realpath "$target_path")" \
            "$(gum style --underline "$target_path")")
        echo "scratch file saved: $saved_path"
      else
        echo "scratch file discarded"
      fi

      rm -f "$temp_file"
    '';
  };
in {
  home.packages = [scratch-file];
}
