{
  perSystem = {pkgs, ...}: let
    # bpf keys on thread ids, so threads and children of already running apps stay in the tunnel
    daemon = pkgs.python3Packages.proton-vpn-daemon.overridePythonAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace proton/vpn/daemon/split_tunneling/apps/socket_monitor.py \
            --replace-fail "u32 pid = bpf_get_current_pid_tgid();" "u32 pid = bpf_get_current_pid_tgid() >> 32;"
          substituteInPlace proton/vpn/daemon/split_tunneling/apps/process_monitor.bpf.c \
            --replace-fail "data.ppid = args->parent_pid;" "data.ppid = bpf_get_current_pid_tgid() >> 32;"
        '';
    });
  in {
    # proton's app-matching daemon, run standalone with a fixed app list
    packages.proton-vpn-split-tunnel = pkgs.writeTextFile {
      name = "proton-vpn-split-tunnel";
      destination = "/bin/proton-vpn-split-tunnel";
      executable = true;
      text = ''
        #!${daemon.pythonModule.withPackages (_: [daemon])}/bin/python
        ${builtins.readFile ./split-tunnel.py}
      '';
      meta.mainProgram = "proton-vpn-split-tunnel";
      # upstream's own value, built into daemon >= 0.13.8
      passthru.fwmark = 245447468;
    };
  };
}
