{
  inputs,
  self,
  ...
}: {
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

    extra-media = {pkgs, ...}: {
      environment.systemPackages = [pkgs.ffmpeg-full pkgs.obs-studio pkgs.eog pkgs.mpv];
    };

    extra-pdf = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.pdftk
        pkgs.poppler-utils
        pkgs.pdfchain
        pkgs.kdePackages.okular
        pkgs.zathura
        pkgs.zathuraPkgs.zathura_pdf_mupdf
        pkgs.jellyfin-desktop
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

    extra-productivity = {pkgs, ...}: {
      environment.systemPackages = [
        pkgs.anki
      ];
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
        self.packages.${system}.ifetch
        self.packages.${system}.mfetch
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
