{pkgs, ...}: let
  gum = "${pkgs.gum}/bin/gum";
  nh = "${pkgs.nh}/bin/nh";
  yazi = "${pkgs.yazi}/bin/yazi";
  fastfetch = "${pkgs.fastfetch}/bin/fastfetch";
  tokei = "${pkgs.tokei}/bin/tokei";
  glow = "${pkgs.glow}/bin/glow";
  yt-dlp = "${pkgs.yt-dlp}/bin/yt-dlp";
  spotdl = "${pkgs.spotdl}/bin/spotdl";
  speedtest-rs = "${pkgs.speedtest-rs}/bin/speedtest-rs";
  browsh = "${pkgs.browsh}/bin/browsh";
  mullvad = {
    vpn = "${pkgs.mullvad-vpn}/bin/mullvad";
    closest = "${pkgs.mullvad-closest}/bin/mullvad-closest";
  };
  nap = "${pkgs.nap}/bin/nap";
  scooter = "${pkgs.scooter}/bin/scooter";
  bat = "${pkgs.bat}/bin/bat";
  btop = "${pkgs.btop}/bin/btop";
  dust = "${pkgs.dust}/bin/dust";
  rip = "${pkgs.rip2}/bin/rip";
  xcp = "${pkgs.xcp}/bin/xcp";
  delta = "${pkgs.delta}/bin/delta";
  fd = "${pkgs.fd}/bin/fd";
  procs = "${pkgs.procs}/bin/procs";
  evcxr = "${pkgs.evcxr}/bin/evcxr";
  sd = "${pkgs.sd}/bin/sd";
  edir = "${pkgs.edir}/bin/edir";
  hx = "${pkgs.helix}/bin/hx";
  lsd = "${pkgs.lsd}/bin/lsd";
  hexyl = "${pkgs.hexyl}/bin/hexyl";
  eva = "${pkgs.eva}/bin/eva";
  navi = "${pkgs.navi}/bin/navi";
  hyperfine = "${pkgs.hyperfine}/bin/hyperfine";
  ripgrep = "${pkgs.ripgrep}/bin/rg";
  ripgrep-all = "${pkgs.ripgrep-all}/bin/rga";
in {
  home.shellAliases = rec {
    # NixOS
    nhrb = "${gum} confirm \"Rebuild system and reload on boot?\" && ${nh} os boot";
    nhrs = "${gum} confirm \"Rebuild system and switch configuration?\" && ${nh} os switch";
    nhrt = "${gum} confirm \"Rebuild system and test?\" && ${nh} os test";
    nhca = "${gum} confirm \"Delete all generations but the last three?\" && ${nh} clean all --keep 3";
    nhs = "${nh} search";
    update =
      "nix flake update --flake $NH_FLAKE" # update
      + "&& ${gum} confirm \"Commit update to main?\"" # prompt
      + "&& cd $NH_FLAKE && git stash" # cd & stash
      + "&& git add flake.nix && git commit -m \"updated at (date -R)\"" # commit
      + "git stash pop && cd -"; # unstash & cd back

    # Configuration
    conf-edit = "$EDITOR $NH_FLAKE";
    config = conf-edit;
    conf = config;

    # Fish
    unset = "set -e";
    whereami = "echo $hostname";

    # Core
    cd = "z"; # zoxide, but not directly a package
    rm = "${rip}";
    cat = "${bat} --theme=ansi";
    du = "${dust}";
    cp = "${xcp}";
    diff = "${delta}";
    top = "${btop}";
    bottom = top;
    htop = top;
    find = "${fd} -HI";
    findg = "${fd} -H";
    ps = "${procs}";
    sed = "${sd}";
    tr = sed;
    vidir = "${edir}";
    oil = vidir;

    # CD
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # ls + tree
    # ls, l, la, lr, lg, tree, treeg
    ls = "${lsd} -F --total-size --group-directories-first --hyperlink auto --git --extensionsort --classify";
    l = "${ls} -1";
    ll = "${ls} -lA";
    lr = "${ll} --recursive";
    tree = "${ls} --tree";

    # Helix
    helix = "${hx}";
    vi = helix;
    vim = helix;
    nvim = helix;

    # Calculator
    calc = "${eva}";
    calculator = calc;

    # Cheatsheet
    cheat = "${navi}";
    cheatsheet = cheat;

    # Hexdump
    xxd = "${hexyl}";
    hexdump = xxd;

    # Grep
    grep = "${ripgrep}";
    grepa = "${ripgrep-all}";

    # Timing
    wtime = "${hyperfine} --runs 1 --warmup 3 --";
    bench = "${hyperfine} --runs 5 --";
    wbench = "${hyperfine} --runs 5 --warmup 3 --";

    # Fetch
    neofetch = "${fastfetch}";
    nerdfetch = neofetch;

    # Yazi
    fm = "${yazi}";

    # EvCxR
    rs-repl = "${evcxr}";
    repl-rs = rs-repl;

    # Tokei
    code-count = "${tokei}";
    count-lines = code-count;
    lines-count = code-count;

    # Glow
    view-md = "${glow}";
    md-view = view-md;

    # Youtube Downloader
    youtube-dl = "${yt-dlp}";
    yt-dl = youtube-dl;

    # Spotify Downloader
    spotify-dl = "${spotdl}";
    sp-dl = spotify-dl;

    # Internet
    speedtest = "${speedtest-rs}";
    vpn = "${mullvad.vpn}";
    vpn-closest = "${mullvad.closest} --max-distance 500 --server-type wireguard";
    browser = "${browsh}";
    browse = browser;

    # Snippets
    snippets = "${nap}";
    snips = snippets;
    snip = snippets;

    # Scooter
    fnr = "${scooter}";
  };
}
