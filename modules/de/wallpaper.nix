{ pkgs, ... }: {
  stylix.image = pkgs.fetchurl {
    url =
      "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox_astro.jpg";
    sha256 = "613c7223ebda0b9086433a8c9b57a77cf87dff5628a8d5c05fb4e602c733d54d";
  };
}
