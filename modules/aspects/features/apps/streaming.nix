{den, ...}: {
  den.aspects.extra.provides.streaming = {
    includes = [(den.batteries.unfree ["cuda_cccl" "cuda_cudart" "cuda_nvcc"])];
    nixos = {
      pkgs,
      lib,
      ...
    }: {
      # moonlight host; cuda build for nvenc, cap_sys_admin for kms capture
      services.sunshine = {
        enable = true;
        package = (pkgs.sunshine.override {cudaSupport = true;}).overrideAttrs (old: {
          postPatch =
            (old.postPatch or "")
            + ''
              # launcher opens the web ui; the service already runs sunshine
              substituteInPlace packaging/linux/dev.lizardbyte.app.Sunshine.desktop \
                --replace-fail 'Exec=sunshine' 'Exec=${lib.getExe' pkgs.xdg-utils "xdg-open"} https://localhost:47990' \
                --replace-fail 'Actions=RunInTerminal;' ""
            '';

          # web ui defaults to its built-in catppuccin mocha theme
          ui = old.ui.overrideAttrs (ui: {
            postPatch =
              (ui.postPatch or "")
              + ''
                substituteInPlace src_assets/common/assets/web/theme.js --replace-fail \
                  "return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'" "return 'mocha'"
              '';
          });
        });
        capSysAdmin = true;
        openFirewall = true;
      };

      # sys_nice: high-priority egl context, so capture keeps up under game load
      security.wrappers.sunshine.capabilities = lib.mkForce "cap_sys_admin,cap_sys_nice+p";

      # steam link
      programs.steam.remotePlay.openFirewall = true;
    };
  };
}
