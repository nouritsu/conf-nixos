{den, ...}: {
  den.aspects.ai = {
    includes = [(den.batteries.unfree ["cursor"])];
    nixos = {
      self',
      inputs',
      pkgs,
      ...
    }: {
      environment.systemPackages = [
        self'.packages.opencode
        self'.packages.claude-code
        inputs'.claude-desktop.packages.claude-desktop
        pkgs.code-cursor

        pkgs.ccusage
        pkgs.claude-monitor
        pkgs.claude-mergetool
      ];

      # electron doesn't know niri and falls back to plaintext
      environment.sessionVariables.CLAUDE_PASSWORD_STORE = "gnome-libsecret";

      # desktop runs its own claude without the wrapper's --settings; managed
      # settings reach every claude. statusLine is tui-only, desktop notifies itself
      environment.etc."claude-code/managed-settings.json".text = let
        inherit (self'.packages.claude-code.configuration) settings;
      in
        builtins.toJSON {
          inherit (settings) attribution permissions;
          hooks = {inherit (settings.hooks) PostToolUse;};
        };

      # claude-mergetool install git can't write the wrapped gitconfig
      programs.git = {
        enable = true;
        config.mergetool.claude = {
          cmd = ''claude-mergetool merge "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'';
          trustExitCode = true;
        };
      };

      programs.fish.shellAbbrs = {
        oc = "opencode";
        c = "claude";
        cr = "claude --resume";
        cn = "claude --continue";
      };
      programs.fish.shellAliases.claude-usage = "ccusage";
    };

    provides.local = {
      includes = [(den.batteries.unfree ["cuda_cccl" "cuda_cudart" "cuda_nvcc" "cuda_nvrtc" "libcublas"])];
      nixos = {
        pkgs,
        lib,
        ...
      }: let
        llama-server = lib.getExe' (pkgs.llama-cpp.override {cudaSupport = true;}) "llama-server";

        # --fit splits layers and moe experts between vram and ram
        serve = model: ctx:
          toString [
            llama-server
            "--port \${PORT}"
            "-hf ${model}"
            "--no-mmproj"
            "--ctx-size ${toString ctx}"
            # qwen's thinking-mode sampling
            "--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0"
          ];
      in {
        # one model at a time, loaded on request, unloaded after 5 idle minutes
        services.llama-swap = {
          enable = true;
          listenAddress = "127.0.0.1";
          settings = {
            # first load downloads the gguf before /health answers
            healthCheckTimeout = 3600;
            globalTTL = 300;

            models = {
              "qwen3.6-35b-a3b".cmd = serve "unsloth/Qwen3.6-35B-A3B-GGUF:UD-Q4_K_XL" 65536;
              "qwen3.5-9b".cmd = serve "unsloth/Qwen3.5-9B-GGUF:UD-Q4_K_XL" 32768;
            };
          };
        };
      };
    };
  };
}
