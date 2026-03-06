{inputs, ...}: {
  flake.nixosModules = {
    extra-tui-viewers = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.binsider
        pkgs.hexyl
        pkgs.glow
      ];

      programs.fish.shellAliases = let
        b = "binsider";
      in {
        view-elf = b;
        view-bin = b;
        view-bytes = "hexyl";
        hexdump = "hexyl";
        view-md = "glow";
      };
    };

    extra-av = {pkgs, ...}: {
      environment.systemPackages = [pkgs.ffmpeg-full];
    };

    extra-pdf = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.pdftk
        pkgs.poppler-utils
      ];
    };

    extra-download = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.wget2
        pkgs.axel
        pkgs.yt-dlp
        pkgs.spotdl
        pkgs.speedtest-rs
      ];

      programs.fish.shellAliases = {
        download = "axel";
        speedtest = "speedtest-rs";
        download-youtube = "yt-dlp";
        download-yt = "yt-dlp";
        download-spotify = "spotdl";
        download-spot = "spotdl";
      };
    };

    extra-fetchers = {
      pkgs,
      config,
      lib,
      ...
    }: {
      environment.systemPackages = let
        system = pkgs.stdenv.hostPlatform.system;
        is_nvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
      in [
        pkgs.nerdfetch
        pkgs.fastfetch
        pkgs.onefetch
        pkgs.cpufetch
        (pkgs.gpufetch.override {cudaSupport = is_nvidia;})
        pkgs.ifetch # overlay
        pkgs.mfetch # overlay
        inputs.batfetch.packages.${system}.default
      ];

      programs.fish.shellAliases = {
        # Fetch
        fetch = "nerdfetch";
        fetch-full = "fastfetch";

        # Applications
        fetch-git = "onefetch";

        # Hardware
        fetch-cpu = "cpufetch";
        fetch-gpu = "gpufetch";
        fetch-mem = "mfetch";
        fetch-net = "ifetch";
        fetch-bat = "batfetch";
      };
    };
  };
}
