{pkgs, ...}: {
  home.packages = [
    pkgs.ouch
    pkgs.unzip
  ];

  programs.fish.shellAbbrs = {
    compress = "ouch compress";
    decompress = "ouch decompress";
  };
}
