import QtQuick
import qs.Modules.Plugins

PluginSettings {
    pluginId: "powerDraw"

    StringSetting {
        settingKey: "priceCt"
        label: "Electricity price"
        description: "ct per kWh, for the energy costs; 0 hides them"
        placeholder: "23.47"
        defaultValue: "0"
    }
}
