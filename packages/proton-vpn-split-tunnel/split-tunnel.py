import asyncio
import json
import logging
import pwd
import signal
import sys

from proton.vpn.core.settings import SplitTunnelingConfig, SplitTunnelingMode
from proton.vpn.daemon.split_tunneling.apps import socket_monitor
from proton.vpn.daemon.split_tunneling.apps.service import AppBasedSplitTunnelingService

MARK = int(sys.argv[1])

# marks from boot, whether or not the vpn is up
if hasattr(socket_monitor, "_get_wireguard_fwmark"):
    socket_monitor._get_wireguard_fwmark = lambda _interface: MARK
elif socket_monitor.FWMARK_VALUE != MARK:
    sys.exit(f"daemon marks {socket_monitor.FWMARK_VALUE}, the bypass rule expects {MARK}")


def load(path):
    with open(path, encoding="utf-8") as file:
        apps = json.load(file)

    config = {}
    for user, paths in apps.items():
        entry = pwd.getpwnam(user)
        config[entry.pw_uid] = SplitTunnelingConfig(
            mode=SplitTunnelingMode.EXCLUDE,
            app_paths=[entry.pw_dir + p[1:] if p.startswith("~/") else p for p in paths],
        )
    return config


async def main():
    service = AppBasedSplitTunnelingService()
    loop = asyncio.get_running_loop()

    stopping = loop.create_future()
    for sig in (signal.SIGTERM, signal.SIGINT):
        loop.add_signal_handler(sig, lambda: stopping.done() or stopping.set_result(None))

    monitor = service.start(load(sys.argv[2]))
    await asyncio.wait([monitor, stopping], return_when=asyncio.FIRST_COMPLETED)

    # detach the bpf, or the cgroup keeps marking stale pids
    await service.stop()
    return stopping.done()


logging.basicConfig(level=logging.INFO, format="%(name)s: %(message)s")
sys.exit(0 if asyncio.run(main()) else 1)
