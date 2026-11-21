import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "columnWidth"

    ToggleSetting {
        settingKey: "alwaysShow"
        label: "Always show"
        description: "Also for full-screen, floating or no windows"
        defaultValue: false
    }
}
