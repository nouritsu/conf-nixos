{inputs, ...}: let
  inherit (inputs) wrappers;
in {
  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    packages.television = wrappers.wrappers.television.wrap [
      {
        inherit pkgs;
        package = pkgs.television;
      }
      {
        settings = {
          # cable channels are written for sh
          shell = "bash";

          # port as overrides; tv only reads theme files from its config dir
          ui.theme = "catppuccin";
          ui.theme_overrides = lib.importTOML "${inputs.catppuccin-television}/themes/catppuccin-mocha-mauve.toml";

          # replaces tv's default triggers
          shell_integration = {
            fallback_channel = "files";
            channel_triggers = {
              alias = ["alias" "funced"];
              dirs = ["cd" "z" "ls" "l" "ll" "lr" "tree" "rmdir" "pushd"];
              files = ["cat" "bat" "hx" "less" "head" "tail" "cp" "xcp" "mv" "rm" "rip" "touch" "chmod" "chown" "ln" "ouch" "xdg-open"];
              git-diff = ["git add" "git restore" "git diff"];
              git-branch = ["git checkout" "git switch" "git branch" "git merge" "git rebase" "git pull" "git push"];
              git-log = ["git log" "git show" "git revert" "git cherry-pick" "git reset"];
              procs = ["kill"];
              tldr = ["tldr"];
              ssh-hosts = ["ssh" "sftp" "ssh-audit"];
            };
          };
        };

        # on top of the builtin files, dirs, text, env and git-* channels
        channels =
          lib.genAttrs [
            "fish-history"
            "zoxide"
            "procs"
            "alias"
            "tldr"
            "man-pages"
            "systemd-units"
            "journal"
            "git-stash"
            "git-worktrees"
            "todo-comments"
          ] (name: "${pkgs.television}/share/cable/unix/${name}.toml")
          // {
            nix = {
              metadata = {
                name = "nix";
                requirements = ["nix-search-tv"];
              };
              source.command = "nix-search-tv print";
              preview.command = "nix-search-tv preview {}";
            };

            # the builtin one reads ~/.ssh/config; these come from the pinned host keys
            ssh-hosts = {
              metadata = {
                name = "ssh-hosts";
                description = "SSH into one of my machines";
                requirements = ["ssh" "ssh-keygen"];
              };
              source.command = ''grep -vx "$(cat /proc/sys/kernel/hostname)" /etc/ssh/hosts'';
              # how ssh will connect, whether a kept connection is open, and the pinned key
              preview.command = ''
                ssh -G '{}' 2>/dev/null | grep -E '^(user|hostname|port|identityagent|forwardagent) '
                ssh -O check '{}' 2>/dev/null && echo 'connection open'
                echo
                ssh-keygen -lv -F '{}' -f /etc/ssh/ssh_known_hosts | tail -n +2
              '';
              keybindings = {
                enter = "actions:connect";
                ctrl-r = "actions:root";
              };
              actions = {
                connect = {
                  description = "SSH into the selected host";
                  command = "ssh '{}'";
                  mode = "execute";
                };
                root = {
                  description = "SSH in as root, with a touch";
                  command = "ssh 'root@{}'";
                  mode = "execute";
                };
              };
            };
          };
      }
    ];
  };
}
