{
  pkgs,
  lib,
  ...
}: let
  getpkg = import ../../../lib/getpkg.nix {inherit pkgs;};

  supported-languages.regex =
    "("
    + lib.concatStrings (builtins.map
      (lang: "^" + lang + "(\\s)+" + "|")
      [
        "bash"
        "c"
        "cpp"
        "cmake"
        "dart"
        "dockerfile"
        "dot"
        "fish"
        "gdscript"
        "go"
        "haskell"
        "javascript"
        "java"
        "json"
        "kotlin"
        "latex"
        "lua"
        "markdown"
        "nix"
        "glsl"
        "perl"
        "prolog"
        "python"
        "rust"
        "sql"
        "typescript"
        "vhdl"
        "wgsl"
        "yaml"
      ]
      ++ ["zig"]) # in my defence, it looked cool
    + ")";
in {
  home.shellAliases = rec {
    # NixOS
    nix = "${getpkg.named {
      name = "nix-output-monitor";
      bin = "nom";
    }}";
    nhrb = "${getpkg.default "gum"} confirm \"Rebuild system and reload on boot?\" && ${getpkg.default "nh"} os boot";
    nhrs = "${getpkg.default "gum"} confirm \"Rebuild system and switch configuration?\" && ${getpkg.default "nh"} os switch";
    nhrt = "${getpkg.default "gum"} confirm \"Rebuild system and test?\" && ${getpkg.default "nh"} os test";
    nhca = "${getpkg.default "gum"} confirm \"Delete all generations but the last three?\" && ${getpkg.default "nh"} clean all --keep 3";
    nhs = "${getpkg.default "nh"} search";
    update =
      "nix flake update --flake $FLAKE"
      + "&& ${cd} $FLAKE && git add flake.lock && git commit -m \"update\" && git push && ${cd} -"
      + "&& ${getpkg.default "nh"} os switch";
    conf-edit = "$EDITOR $FLAKE && ${nhrt}";
    config = conf-edit;
    conf = config;

    # Fish
    unset = "set -e";
    whereami = "echo $hostname";

    # Core
    cd = "z"; # zoxide, but not directly a package
    cat = "${getpkg.default "bat"}";
    top = "${getpkg.default "btop"}";
    bottom = top;
    htop = top;
    du = "${getpkg.default "dust"}";
    rm = "${getpkg.named {
      name = "rip2";
      bin = "rip";
    }}";
    awk = "${getpkg.default "frawk"}";
    cp = "${getpkg.default "xcp"}";
    diff = "${getpkg.default "delta"}";
    find = "${getpkg.default "fd"} -HI";
    findg = "${getpkg.default "fd"} -H";
    ps = "${getpkg.default "procs"}";
    sed = "${getpkg.default "sd"}";
    tr = sed;
    vidir = "${getpkg.default "edir"}";
    oil = vidir;

    # CD
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";

    # ls/tree
    ls = "${getpkg.default "eza"} --sort=extension --icons=auto --group-directories-first --mounts";
    l = "ls -hla --total-size";
    ll = "l --git --git-repos";
    tree = "ll --tree";
    lg = "ll --git-ignore";
    treeg = "tree --git --git-repos --git-ignore";

    # Helix
    helix = "${getpkg.named {
      name = "helix";
      bin = "hx";
    }}";
    vi = helix;
    vim = helix;
    nvim = helix;
    hx-health = "helix --health | ${pkgs.ripgrep}/bin/rg \"${supported-languages.regex}\"";

    # Calculator
    calc = "${getpkg.default "eva"}";
    calculator = calc;

    # Cheatsheet
    cheat = "${getpkg.default "navi"}";
    cheatsheet = cheat;

    # Hexdump
    xxd = "${getpkg.default "hexyl"}";
    hexdump = xxd;

    # Grep
    grep = "${getpkg.named {
      name = "ripgrep";
      bin = "rg";
    }}";
    grepa = "${getpkg.named {
      name = "ripgrep-all";
      bin = "rga";
    }}";

    # Timing
    wtime = "${getpkg.default "hyperfine"} --runs 1 --warmup 3";
    bench = "${getpkg.default "hyperfine"} --runs 5 --warmup 3";

    # Fetch
    neofetch = "${getpkg.default "fastfetch"}";
    nerdfetch = neofetch;

    # JQL
    jq = "${getpkg.default "jql"}";

    # Yazi
    fm = "${getpkg.default "yazi"}";

    # Tokei
    code-count = "${getpkg.default "tokei"}";
    count-lines = code-count;
    lines-count = code-count;

    # Glow
    view-md = "${getpkg.default "glow"}";
    md-view = view-md;

    # Youtube Downloader
    youtube-dl = "${getpkg.default "yt-dlp"}";
    yt-dl = youtube-dl;

    # Spotify Downloader
    spotify-dl = "${getpkg.default "spotdl"}";
    sp-dl = spotify-dl;

    # Internet
    speedtest = "${getpkg.default "speedtest-rs"}";
    vpn = "${getpkg.named {
      name = "mullvad-vpn";
      bin = "mullvad";
    }}";
    vpn-closest = "${getpkg.default "mullvad-closest"} --max-distance 500 --server-type wireguard";
    browser = "${getpkg.default "browsh"}";
    browse = browser;

    # Snippets
    snippets = "${getpkg.default "nap"}";
    snips = snippets;
    snip = snippets;

    # Scooter
    fnr = "${getpkg.default "scooter"}";
  };
}
