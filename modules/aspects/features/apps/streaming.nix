{
  den.aspects.extra.provides.streaming = {
    nixos = {
      config,
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

              # tray/web ui restart re-execs through the wrapper; /proc/self/exe has no caps, so kms broke
              substituteInPlace src/platform/linux/misc.cpp --replace-fail \
                'execv(executable, lifetime::get_argv())' 'execv("${config.security.wrapperDir}/sunshine", lifetime::get_argv())'
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

      # sunshine still sets the obsolete avahi.publish options; same effect via settings
      services.avahi = {
        publish = {
          enable = null;
          userServices = null;
        };
        settings.publish = {
          disable-publishing = false;
          disable-user-service-publishing = false;
          publish-addresses = true;
        };
      };

      # sys_nice: high-priority egl context, so capture keeps up under game load
      security.wrappers.sunshine.capabilities = lib.mkForce "cap_sys_admin,cap_sys_nice+p";

      # steam link
      programs.steam.remotePlay.openFirewall = true;
    };
  };
}
