import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    readonly property var weatherIcons: ({
        "113": "☀️",
        "116": "⛅",
        "119": "☁️",
        "122": "☁️",
        "143": "🌫️",
        "176": "🌦️",
        "179": "🌧️",
        "182": "🌧️",
        "185": "🌧️",
        "200": "⛈️",
        "227": "🌨️",
        "230": "❄️",
        "248": "🌫️",
        "260": "🌫️",
        "263": "🌧️",
        "266": "🌧️",
        "281": "🌧️",
        "284": "🌧️",
        "293": "🌧️",
        "296": "🌧️",
        "299": "🌧️",
        "302": "❄️",
        "305": "🌧️",
        "308": "❄️",
        "311": "🌧️",
        "314": "🌧️",
        "317": "🌧️",
        "320": "🌨️",
        "323": "🌨️",
        "326": "🌨️",
        "329": "❄️",
        "332": "❄️",
        "335": "❄️",
        "338": "❄️",
        "350": "🌧️",
        "353": "🌧️",
        "356": "🌧️",
        "359": "❄️",
        "362": "🌧️",
        "365": "🌧️",
        "368": "🌨️",
        "371": "❄️",
        "374": "🌧️",
        "377": "🌧️",
        "386": "⛈️",
        "389": "⛈️",
        "392": "⛈️",
        "395": "❄️"
    })
    property string location
    property string icon
    property string desc
    property string temp

    function getWeatherIcon(code: string) : string {
        if (weatherIcons.hasOwnProperty(code))
            return weatherIcons[code];

        return "🍃";
    }

    function fetchWeather() {
        if (!location || location === "REPLACE")
            return ;

        Requests.get(`https://wttr.in/${location}?format=j1`, (text) => {
            try {
                const data = JSON.parse(text);
                if (!data || !data.current_condition || !data.current_condition[0])
                    return ;

                const json = data.current_condition[0];
                root.icon = root.getWeatherIcon(json.weatherCode);
                root.desc = json.weatherDesc[0].value;
                root.temp = `${parseFloat(json.temp_C)}°C`;
            } catch (e) {
                console.warn("[Weather] Failed to parse response:", e);
            }
        });
    }

    function reload() {
        if (Config.settings.weatherLocation) {
            if (location != Config.settings.weatherLocation)
                location = Config.settings.weatherLocation;
            else
                fetchWeather();
        } else if (!location) {
            location = "REPLACE";
        }
    }

    onLocationChanged: {
        if (location == "REPLACE") {
            root.icon = "❌";
            root.desc = "No location set.";
            root.temp = "Error.";
            return ;
        }
        fetchWeather();
    }
    Component.onCompleted: reload()

    Timer {
        interval: 300000
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }

}
