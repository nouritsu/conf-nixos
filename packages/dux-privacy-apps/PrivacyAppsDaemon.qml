pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.Common
import qs.Services
import qs.Modules.Plugins

PluginComponent {
    id: root

    // app key -> {name, icon, mic, camera, screen}; held until unblocked or dux restarts
    property var blocks: ({})

    // app key -> {name, icon}; kept in plugin state until shown again
    property var hidden: ({})

    // binaries ignored in config, never shown
    readonly property var ignored: pluginData.ignore ?? []

    // stream pid -> {top, exe}; null once the /proc lookup failed
    property var owners: ({})

    property var _resolving: ({})
    // node id -> app key, for the streams a block muted
    property var _mutedByUs: ({})
    // app keys unblocked with no stream open; wireplumber restores their next one muted
    property var _released: ({})
    property var _cutting: ({})
    property var _stopping: ({})

    // quickshell only types audio streams; video streams are untracked nodes, bound here for their props
    PwObjectTracker {
        objects: Pipewire.nodes.values.filter(node => node && (node.isStream || node.type === PwNodeType.Untracked))
    }

    // every stream behind the indicator, one entry per stream or screencopy cast
    readonly property var uses: {
        const owners = root.owners;
        const nodes = Pipewire.nodes.values;
        const casts = CompositorService.isNiri ? NiriService.casts.filter(cast => cast.is_active) : [];

        // screencast sources: niri's cast nodes, or anything that looks like one elsewhere
        const castByNode = {};
        for (const cast of casts) {
            if (cast.pw_node_id != null)
                castByNode[cast.pw_node_id] = cast;
        }
        const screenSources = new Set(Object.keys(castByNode).map(Number));
        if (!CompositorService.isNiri) {
            for (const node of nodes) {
                if (node && AudioService.isPipewireVideoSource(node) && PrivacyService.looksLikeScreencast(node))
                    screenSources.add(node.id);
            }
        }

        // their consumers
        const consumers = {};
        for (const group of Pipewire.linkGroups.values) {
            if (group?.source && group?.target && screenSources.has(group.source.id))
                consumers[group.target.id] = castByNode[group.source.id] ?? null;
        }

        const out = [];
        const add = (kind, node, cast, props) => {
            const pid = parseInt(props["application.process.id"] ?? "") || 0;
            const owner = pid ? owners[pid] : null;
            const resolving = pid > 0 && owner === undefined;
            const key = resolving ? "" : owner?.exe || props["application.process.binary"] || props["application.name"] || props["node.name"] || "";
            const canBlock = kind === "mic" ? !!node?.audio : kind === "camera" ? !!node : cast ? cast.kind === "PipeWire" : !!node;
            out.push({
                kind,
                node,
                cast,
                props,
                pid,
                owner,
                key,
                canBlock: canBlock && key !== "",
                muted: node?.audio?.muted ?? false,
                // the binary covers the moment the owner is still resolving
                ignore: ignoreOf(key) || ignoreOf(props["application.process.binary"] ?? "")
            });
        };

        for (const node of nodes) {
            const props = node?.properties ?? {};
            const mediaClass = props["media.class"] ?? "";
            if (!mediaClass.startsWith("Stream/"))
                continue;
            if (mediaClass === "Stream/Input/Audio" && !PrivacyService.looksLikeSystemVirtualMic(node))
                add("mic", node, null, props);
            else if (node.id in consumers)
                add("screen", node, consumers[node.id], props);
            else if (mediaClass === "Stream/Input/Video" && props["media.role"] !== "Screen" && props["stream.is-live"] === "true")
                add("camera", node, null, props);
        }

        // screencopy casts have a pid but no pipewire node
        for (const cast of casts) {
            if (cast.pw_node_id == null && cast.kind !== "PipeWire")
                add("screen", null, cast, cast.pid ? {
                    "application.process.id": String(cast.pid)
                } : {});
        }

        return out;
    }

    readonly property bool micActive: uses.some(use => use.kind === "mic" && !use.muted && !use.ignore)
    // camera only; dux's own check counts screen captures too
    readonly property bool cameraActive: uses.some(use => use.kind === "camera" && !use.ignore)

    // kinds whose every stream is ignored; the pill stays dark for them
    readonly property var ignoredOnly: {
        const kinds = {};
        for (const kind of ["mic", "camera", "screen"]) {
            const streams = uses.filter(use => use.kind === kind);
            kinds[kind] = streams.length > 0 && streams.every(use => use.ignore);
        }
        return kinds;
    }

    readonly property var blockedKinds: {
        const kinds = {
            "mic": false,
            "camera": false,
            "screen": false
        };
        for (const key in blocks) {
            if (ignoreOf(key))
                continue;
            for (const kind in kinds)
                kinds[kind] = kinds[kind] || blocks[key][kind];
        }
        return kinds;
    }

    // uses grouped per app, plus blocked or hidden apps with nothing open so they can be undone
    readonly property var apps: {
        const groups = {};
        for (const use of uses) {
            const top = use.owner?.top ?? use.pid;
            const id = top ? `pid:${top}` : use.node ? `node:${use.node.id}` : `cast:${use.cast?.stream_id}`;
            const app = groups[id] ?? (groups[id] = describe(id, use, top));
            app.kinds[use.kind] = true;
            if (use.canBlock)
                app.blockable[use.kind] = true;
        }

        const present = new Set(Object.values(groups).map(app => app.key));
        for (const [key, entry] of Object.entries(blocks).concat(Object.entries(hidden))) {
            if (present.has(key))
                continue;
            present.add(key);
            groups[`absent:${key}`] = {
                id: `absent:${key}`,
                key,
                pid: 0,
                name: entry.name,
                icon: entry.icon,
                ignore: ignoreOf(key),
                kinds: {},
                blockable: {}
            };
        }

        return Object.values(groups).sort((a, b) => a.name.localeCompare(b.name));
    }

    // "config", "hidden" or ""
    function ignoreOf(key) {
        if (!key)
            return "";
        if (ignored.includes(key))
            return "config";
        return hidden[key] ? "hidden" : "";
    }

    // name and icon: the app's window first, then the stream's own props
    function describe(id, use, top) {
        const props = use.props;
        const window = top ? NiriService.windows.find(w => w.pid === top) : null;
        const candidates = [window?.app_id, props["pipewire.access.portal.app_id"], props["application.icon-name"], use.owner?.exe, props["application.process.binary"], props["application.name"], props["node.name"]].filter(candidate => !!candidate);
        let appId = candidates[0] ?? "";
        let entry = null;
        for (const candidate of candidates) {
            entry = DesktopEntries.heuristicLookup(Paths.moddedAppId(candidate));
            if (entry) {
                appId = candidate;
                break;
            }
        }
        return {
            id,
            key: use.key,
            pid: top,
            name: entry ? Paths.getAppName(appId, entry) : props["application.name"] || appId || (top ? `PID ${top}` : "Unknown app"),
            icon: appId ? Paths.getAppIcon(appId, entry) : "",
            ignore: use.ignore,
            kinds: {},
            blockable: {}
        };
    }

    function setHidden(app, on) {
        if (!app.key)
            return;
        const next = Object.assign({}, hidden);
        if (on)
            next[app.key] = {
                "name": app.name,
                "icon": app.icon
            };
        else
            delete next[app.key];
        hidden = next;
        PluginService.savePluginState(pluginId, "hidden", next);
    }

    function setBlocked(app, kind, on) {
        if (!app.key)
            return;
        const block = Object.assign({
            "name": app.name,
            "icon": app.icon,
            "mic": false,
            "camera": false,
            "screen": false
        }, blocks[app.key] ?? {});
        block[kind] = on;

        const next = Object.assign({}, blocks);
        if (block.mic || block.camera || block.screen)
            next[app.key] = block;
        else
            delete next[app.key];
        blocks = next;

        if (kind !== "mic")
            return;
        if (on)
            delete _released[app.key];
        else
            unmute(app.key);
    }

    // the focused window's app, keyed like its streams; kind is mic, camera, screen or all
    function setFocusedBlocked(kind, on) {
        const kinds = kind === "all" ? ["mic", "camera", "screen"] : [kind];
        if (!["mic", "camera", "screen"].includes(kinds[0]))
            return `unknown kind: ${kind}`;
        const window = NiriService.windows.find(w => w.is_focused);
        if (!window?.pid)
            return "no focused window";

        Proc.runCommand(null, ["@owner@", String(window.pid)], (output, exitCode) => {
            const exe = output.trim().split(" ")[1];
            if (exitCode !== 0 || !exe)
                return;
            const appId = window.app_id ?? "";
            const entry = appId ? DesktopEntries.heuristicLookup(Paths.moddedAppId(appId)) : null;
            const app = {
                "key": exe,
                "name": entry ? Paths.getAppName(appId, entry) : appId || exe,
                "icon": appId ? Paths.getAppIcon(appId, entry) : ""
            };
            // a mic unblock with nothing blocked would still unmute its next stream
            for (const k of kinds.filter(k => on || blocks[exe]?.[k]))
                setBlocked(app, k, on);
        }, 0);
        return "ok";
    }

    function kill(app, signal) {
        if (app.pid > 0)
            Quickshell.execDetached(["kill", "-" + signal, String(app.pid)]);
    }

    function unmute(key) {
        let open = false;
        for (const use of uses) {
            if (use.kind !== "mic" || use.key !== key)
                continue;
            open = true;
            if (_mutedByUs[use.node.id] !== undefined) {
                use.node.audio.muted = false;
                delete _mutedByUs[use.node.id];
            }
        }
        if (!open)
            _released[key] = true;
    }

    function enforce() {
        for (const use of uses) {
            if (use.kind === "mic" && _released[use.key]) {
                delete _released[use.key];
                if (use.muted)
                    use.node.audio.muted = false;
                continue;
            }

            if (!use.canBlock || !blocks[use.key]?.[use.kind])
                continue;

            if (use.kind === "mic") {
                if (!use.muted)
                    use.node.audio.muted = true;
                _mutedByUs[use.node.id] = use.key;
            } else if (use.cast?.kind === "PipeWire") {
                if (!_stopping[use.cast.session_id]) {
                    _stopping[use.cast.session_id] = true;
                    NiriService.send({
                        "Action": {
                            "StopCast": {
                                "session_id": use.cast.session_id
                            }
                        }
                    });
                }
            } else if (!_cutting[use.node.id]) {
                _cutting[use.node.id] = true;
                Quickshell.execDetached(["pw-cli", "destroy", String(use.node.id)]);
            }
        }
    }

    function resolveOwners() {
        for (const use of uses) {
            const pid = use.pid;
            if (!pid || pid in owners || _resolving[pid])
                continue;
            _resolving[pid] = true;
            Proc.runCommand(null, ["@owner@", String(pid)], (output, exitCode) => {
                delete _resolving[pid];
                const [top, exe] = output.trim().split(" ");
                const next = Object.assign({}, root.owners);
                next[pid] = exitCode === 0 && exe ? {
                    "top": parseInt(top),
                    "exe": exe
                } : null;
                root.owners = next;
            }, 0);
        }
    }

    // forget pids, nodes and casts that are gone; pids get reused
    function prune() {
        const pids = new Set(uses.map(use => use.pid));
        const nodes = new Set(uses.filter(use => use.node).map(use => use.node.id));
        const sessions = new Set(uses.filter(use => use.cast).map(use => use.cast.session_id));

        const stale = Object.keys(owners).filter(pid => !pids.has(Number(pid)));
        if (stale.length > 0) {
            const next = Object.assign({}, owners);
            for (const pid of stale)
                delete next[pid];
            owners = next;
        }
        for (const id in _mutedByUs) {
            if (!nodes.has(Number(id)))
                delete _mutedByUs[id];
        }
        for (const id in _cutting) {
            if (!nodes.has(Number(id)))
                delete _cutting[id];
        }
        for (const id in _stopping) {
            if (!sessions.has(Number(id)))
                delete _stopping[id];
        }
    }

    onUsesChanged: {
        resolveOwners();
        Qt.callLater(enforce);
        Qt.callLater(prune);
    }
    onBlocksChanged: Qt.callLater(enforce)

    // dms ipc call privacyApps <block|unblock> <mic|camera|screen|all>
    IpcHandler {
        target: "privacyApps"

        function block(kind: string): string {
            return root.setFocusedBlocked(kind, true);
        }

        function unblock(kind: string): string {
            return root.setFocusedBlocked(kind, false);
        }
    }

    Component.onCompleted: hidden = PluginService.loadPluginState(pluginId, "hidden", {})

    // blocks die with dux; don't leave their streams muted
    Component.onDestruction: {
        for (const use of uses) {
            if (use.node?.audio && _mutedByUs[use.node.id] !== undefined)
                use.node.audio.muted = false;
        }
    }
}
