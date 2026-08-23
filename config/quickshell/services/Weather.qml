import QtQuick
import Quickshell
import Quickshell.Io
import qs.core
import qs.services
pragma Singleton

Singleton {
    id: root

    readonly property var weatherIcons: ({
        "113": "wb_sunny",
        "116": "partly_cloudy_day",
        "119": "cloud",
        "122": "cloudy",
        "143": "foggy",
        "176": "rainy",
        "179": "weather_snowy",
        "182": "weather_snowy",
        "185": "weather_snowy",
        "200": "thunderstorm",
        "227": "weather_snowy",
        "230": "severe_cold",
        "248": "foggy",
        "260": "foggy",
        "263": "rainy",
        "266": "rainy",
        "281": "weather_snowy",
        "284": "weather_snowy",
        "293": "rainy",
        "296": "rainy",
        "299": "rainy",
        "302": "rainy",
        "305": "rainy_heavy",
        "308": "rainy_heavy",
        "311": "weather_snowy",
        "314": "weather_snowy",
        "317": "weather_snowy",
        "320": "weather_snowy",
        "323": "weather_snowy",
        "326": "weather_snowy",
        "329": "weather_snowy",
        "332": "weather_snowy",
        "335": "weather_snowy",
        "338": "weather_snowy",
        "350": "weather_snowy",
        "353": "rainy",
        "356": "rainy_heavy",
        "359": "rainy_heavy",
        "362": "weather_snowy",
        "365": "weather_snowy",
        "368": "weather_snowy",
        "371": "weather_snowy",
        "374": "weather_snowy",
        "377": "weather_snowy",
        "386": "thunderstorm",
        "389": "thunderstorm",
        "392": "thunderstorm",
        "395": "thunderstorm"
    })
    property string location: ""
    property string icon: "partly_cloudy_day"
    property string desc: "Loading..."
    property string temp: "--"
    property real tempNum: 0
    property string feelsLike: "--"
    property string humidity: "--"
    property string windSpeed: "--"
    property bool isLoading: false
    property bool hasError: false

    function getWeatherIcon(code: string) : string {
        if (code && weatherIcons.hasOwnProperty(code))
            return weatherIcons[code];

        return "partly_cloudy_day";
    }

    function fetchWeather() {
        if (!location || location === "REPLACE" || location.trim() === "") {
            root.icon = "cloud_off";
            root.desc = "No location set";
            root.temp = "--";
            root.hasError = true;
            return ;
        }
        root.isLoading = true;
        root.hasError = false;
        Requests.get(`https://wttr.in/${encodeURIComponent(location)}?format=j1`, (text) => {
            root.isLoading = false;
            try {
                const data = JSON.parse(text);
                if (!data || !data.current_condition || !data.current_condition[0]) {
                    root.hasError = true;
                    return ;
                }
                const json = data.current_condition[0];
                root.icon = root.getWeatherIcon(String(json.weatherCode));
                root.desc = (json.weatherDesc && json.weatherDesc[0]) ? json.weatherDesc[0].value.trim() : "";
                root.tempNum = parseFloat(json.temp_C) || 0;
                root.temp = `${Math.round(root.tempNum)}°C`;
                root.feelsLike = json.FeelsLikeC ? `${Math.round(parseFloat(json.FeelsLikeC))}°C` : "--";
                root.humidity = json.humidity ? `${json.humidity}%` : "--";
                root.windSpeed = json.windspeedKmph ? `${json.windspeedKmph} km/h` : "--";
                root.hasError = false;
            } catch (e) {
                console.warn("[Weather] Failed to parse response:", e);
                root.hasError = true;
            }
        });
    }

    function reload() {
        let loc = Config.get("weatherLocation", "Guayaquil");
        if (loc && loc.length > 0) {
            if (location !== loc)
                location = loc;
            else
                fetchWeather();
        } else if (!location) {
            location = "Guayaquil";
        }
    }

    onLocationChanged: {
        if (location === "REPLACE" || !location || location.trim() === "") {
            root.icon = "cloud_off";
            root.desc = "No location set.";
            root.temp = "--";
            root.hasError = true;
            return ;
        }
        fetchWeather();
    }
    Component.onCompleted: reload()

    Connections {
        function onWeatherLocationChanged() {
            root.reload();
        }

        target: Config.settings
    }

    Timer {
        interval: 300000 // 5 minutes
        running: true
        repeat: true
        onTriggered: root.fetchWeather()
    }

}
