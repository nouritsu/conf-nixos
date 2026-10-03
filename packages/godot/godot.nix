{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: let
    bin = name: "/run/current-system/sw/bin/${name}";

    # forced into editor_settings on launch, if the program exists
    settings = [
      {
        # Godot only checks fixed FHS paths, and dismissing its prompt
        # turns .blend import off in project.godot
        key = "filesystem/import/blender/blender_path";
        value = bin "blender";
        needs = ["blender"];
      }
      {
        key = "filesystem/external_programs/raster_image_editor";
        value = bin "aseprite";
        needs = ["aseprite"];
      }
      {
        key = "filesystem/external_programs/3d_model_editor";
        value = bin "blender";
        needs = ["blender"];
      }
      {
        key = "filesystem/external_programs/audio_editor";
        value = bin "audacity";
        needs = ["audacity"];
      }
      {
        key = "filesystem/external_programs/terminal_emulator";
        value = bin "wezterm";
        needs = ["wezterm"];
      }
      {
        key = "filesystem/external_programs/terminal_emulator_flags";
        value = "start --cwd {directory}";
        needs = ["wezterm"];
      }
      {
        key = "text_editor/external/use_external_editor";
        value = true;
        needs = ["wezterm" "hx"];
      }
      {
        key = "text_editor/external/exec_path";
        value = bin "wezterm";
        needs = ["wezterm" "hx"];
      }
      {
        key = "text_editor/external/exec_flags";
        value = "start --cwd {project} -- ${bin "hx"} {file}:{line}:{col}";
        needs = ["wezterm" "hx"];
      }
    ];

    tres = "editor_settings-${lib.versions.majorMinor pkgs.godot.version}.tres";

    enforce = pkgs.writeShellApplication {
      name = "godot-editor-settings";
      runtimeInputs = [pkgs.gawk pkgs.coreutils];
      text = ''
        file=''${XDG_CONFIG_HOME:-$HOME/.config}/godot/${tres}
        mkdir -p "''${file%/*}"
        [[ -s $file ]] || printf '[gd_resource type="EditorSettings" format=3]\n\n[resource]\n' >"$file"

        # key<TAB>value, one per line, for the settings whose programs exist
        want=""
        ${lib.concatMapStrings (s: ''
            if ${lib.concatMapStringsSep " && " (p: "[[ -x ${bin p} ]]") s.needs}; then
              want+=${lib.escapeShellArg "${s.key}\t${builtins.toJSON s.value}"}$'\n'
            fi
          '')
          settings}

        # replace in place; new keys go to [resource], the last section
        WANT=$want awk '
          BEGIN {
            n = split(ENVIRON["WANT"], lines, "\n")
            for (i = 1; i <= n; i++) if (lines[i] != "") {
              split(lines[i], kv, "\t"); keys[++k] = kv[1]; val[kv[1]] = kv[2]
            }
          }
          {
            for (i = 1; i <= k; i++) if (index($0, keys[i] " = ") == 1) {
              print keys[i] " = " val[keys[i]]; done[keys[i]] = 1; next
            }
            print
          }
          END { for (i = 1; i <= k; i++) if (!(keys[i] in done)) print keys[i] " = " val[keys[i]] }
        ' "$file" >"$file.tmp"
        mv "$file.tmp" "$file"
      '';
    };
  in {
    packages.godot = wrappers.lib.wrapPackage [
      {
        inherit pkgs;
        package = pkgs.godot;
      }
      {
        # never keep Godot from starting over its settings file
        runShell = ["${lib.getExe enforce} || true"];
      }
    ];
  };
}
