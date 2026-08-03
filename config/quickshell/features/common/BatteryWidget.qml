import QtQuick
import QtQuick.Controls
import qs.core
import qs.features.common

Text {
    text: {
        if (Battery.charging == false) {
            if (Battery.percent <= 10)
                return "battery_0_bar";
            else if (Battery.percent <= 20)
                return "battery_1_bar";
            else if (Battery.percent <= 30)
                return "battery_2_bar";
            else if (Battery.percent <= 40)
                return "battery_3_bar";
            else if (Battery.percent <= 60)
                return "battery_4_bar";
            else if (Battery.percent <= 80)
                return "battery_5_bar";
            else if (Battery.percent <= 90)
                return "battery_6_bar";
            else
                return "battery_full";
        } else {
            if (Battery.percent <= 10)
                return "battery_charging_full";
            else if (Battery.percent <= 20)
                return "battery_charging_20";
            else if (Battery.percent <= 30)
                return "battery_charging_30";
            else if (Battery.percent <= 40)
                return "battery_charging_50";
            else if (Battery.percent <= 60)
                return "battery_charging_60";
            else if (Battery.percent <= 80)
                return "battery_charging_80";
            else if (Battery.percent <= 90)
                return "battery_charging_90";
            else
                return "battery_charging_full";
        }
    }
}
