import QtQuick
pragma Singleton

QtObject {
    readonly property var definitions: [{
        "widgetId": "systray",
        "displayName": "System Tray",
        "iconCode": "apps",
        "previewIcon": "apps",
        "previewText": "Tray",
        "previewWidth": 70
    }, {
        "widgetId": "recording",
        "displayName": "Recording",
        "iconCode": "screen_record",
        "previewIcon": "screen_record",
        "previewText": "REC",
        "previewWidth": 68
    }, {
        "widgetId": "notifications",
        "displayName": "Notifications",
        "iconCode": "notifications",
        "previewIcon": "notifications",
        "previewText": "3",
        "previewWidth": 54
    }, {
        "widgetId": "quickactions",
        "displayName": "Quick Status & Actions",
        "iconCode": "dashboard",
        "previewIcon": "schedule",
        "previewIcons": ["schedule", "wifi", "battery_full"],
        "previewText": "12:34",
        "previewWidth": 130
    }, {
        "widgetId": "cpu",
        "displayName": "CPU",
        "iconCode": "memory",
        "previewIcon": "memory",
        "previewText": "38%",
        "previewWidth": 64
    }, {
        "widgetId": "ram",
        "displayName": "RAM",
        "iconCode": "storage",
        "previewIcon": "storage",
        "previewText": "61%",
        "previewWidth": 64
    }, {
        "widgetId": "temp",
        "displayName": "Temperature",
        "iconCode": "thermostat",
        "previewIcon": "thermostat",
        "previewText": "52°C",
        "previewWidth": 70
    }]

    function definitionForId(widgetId) {
        if (!widgetId)
            return null;

        const normalized = String(widgetId).toLowerCase();
        for (let i = 0; i < definitions.length; i++) {
            if (definitions[i].widgetId === normalized)
                return definitions[i];

        }
        return null;
    }

    function displayName(widgetId) {
        const def = definitionForId(widgetId);
        return def ? def.displayName : widgetId;
    }

    function previewWidth(widgetId) {
        const def = definitionForId(widgetId);
        return def ? def.previewWidth : 60;
    }

}
